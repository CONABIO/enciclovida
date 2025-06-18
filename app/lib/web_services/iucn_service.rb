class WebServices::IucnService

  attr_accessor :datos, :row, :validacion, :taxon

  VERSION_IUCN = "2021-1"
  CATEGORIAS_IUCN = { 
    'Data Deficient' => 'DD',
    'Least Concern' => 'LC',
    'Near Threatened' => 'NT',
    'Vulnerable' => 'VU',
    'Endangered' => 'EN',
    'Critically Endangered' => 'CR',
    'Extinct in The Wild' => 'EW',
    'Extinct' => 'EX'
  }

  SUBPOBLACIONES = {
    'Atlantic subpopulation' => 'Atlántico',
    'East Pacific Ocean subpopulation' => 'Este del Océano Pacífico',
    'East Pacific subpopulation' => 'Pacífico Este',
    'Eastern North Pacific subpopulation' => 'Pacífico Norte Oriental',
    'Eastern Pacific subpopulation' => 'Pacífico Oriental',
    'North Pacific subpopulation' => 'Pacífico Norte',
    'North West Atlantic subpopulation' => 'Atlántico Noroeste',
    'Northeast Pacific subpopulation' => 'Noreste del Pacífico',
    'Northwest Atlantic Ocean subpopulation' => 'Noroeste del Océano Atlántico',
    'Western Atlantic subpopulation' => 'Atlántico Occidental',
    'Western subpopulation' => 'Occidenta'
  }

  SALTA_CASOS = ['Búsqueda similar', 'Sin coincidencias']

  # Enceuntra la descripcion por el nombre cientifico en IUCN
  def encuentra_descripcion
    endpoint = "species/narrative/#{taxon.nombre_cientifico.limpiar(tipo: 'ssp')}"
    consulta_api(endpoint)

    return if datos[:estatus]
    
    # Busco en sinonimos
    sinonimos = taxon.especies_estatus.sinonimos
    
    if sinonimos.any?
      sinonimos.each do |sinonimo|
        endpoint = "species/narrative/#{sinonimo.especie.nombre_cientifico.limpiar(tipo: 'ssp')}"
        consulta_api(endpoint)   
        return if datos[:estatus]
      end
    else
      self.datos = { estatus: false, msg: 'No hubo resultados' }
    end
  end

  # Consulta la categoria de riesgo de un taxon dado
  def consultaRiesgo(opts)
    @iucn = CONFIG.iucn.api
    @token = CONFIG.iucn.token

    url = "#{@iucn}/api/v3/species/#{opts[:nombre].limpiar(tipo: 'ssp')}?token=#{@token}"
    url_escape = URI.encode_www_form_component(url)
    uri = URI.parse(url_escape)
    req = Net::HTTP::Get.new(uri.to_s)
    begin
      res = Net::HTTP.start(uri.host, uri.port, :read_timeout => CONFIG.iucn.timeout ) {|http| http.request(req) }
      jres = JSON.parse(res.body)['result']
      jres[0]['category'] if jres.any?
    rescue => e
      nil
    end
  end

  # Guarda en cache la respuesta del servicio
  def dameRiesgo(opc={})
    resp = Rails.cache.fetch("iucn_#{opc[:id]}", expires_in: eval(CONFIG.cache.iucn)) do
      iucn = consultaRiesgo(opc)
      I18n.t("iucn_ws.#{iucn.estandariza}", :default => iucn) if iucn.present?
    end

    resp
  end

  # Accede al archivo que contiene los assessments y la taxonomia dentro de la carpeta versiones_IUCN
  # NOTAS: Este archivo se baja de la pagina de IUCN y hay que unir el archivo de asessments con el de taxonomy y guardarlo bajo public/IUCN
  def valida_version_IUCN(archivo)
    csv_path = Rails.root.join('public', 'IUCN', archivo)
    bitacora.puts 'Nombre científico en IUCN,Categoría en IUCN,Subpoblación,Nombre en CAT,IdCAT,Estatus nombre,IdCAT válido,Nombre válido CAT,mensaje,observación RelNombreCatalogo'
    return unless File.exists? csv_path

    CSV.foreach(csv_path, :headers => true) do |r|
      self.row = r
      self.datos = [row['scientificName'], row['redlistCategory'], row['subpopulationName'], nil, nil, nil, nil, nil, nil]  # Se inicializa la respuesta vacia

      v = Validacion.new

      if row['subpopulationName'].present?  # Quita la zona del nombre cientifico ... bien IUCN
        v.nombre_cientifico = row['scientificName'].gsub(row['subpopulationName'], '')
      else
        v.nombre_cientifico = row['scientificName']
      end

      v.nombre_cientifico = v.nombre_cientifico.gsub('ssp.', 'subsp.')
      v.encuentra_por_nombre

      self.validacion = v.validacion
      self.datos[8] = validacion[:msg]

      if validacion[:estatus]
        valida_extras  # Solo un resultado y al menos fue coincidencia
      else
        if validacion[:taxones].present?  # Mas de un resultado
          if datos[8] == 'Existe más de una búsqueda exacta'
            cuantos_encontro = 0

            validacion[:taxones].each do |taxon|
              validacion[:taxon] = taxon
              if valida_extras  # Encontro el verdadero de entre las coincidencias
                self.datos[8] = 'Búsqueda exacta'
                cuantos_encontro+= 1
                break
              end
            end  # End each taxones

            sin_coincidencias if cuantos_encontro == 0

          else  # Si es busqueda similar con multiples coincidencias
            cuantos_encontro = []

            validacion[:taxones].each do |taxon|  # Descartando los que no son de la categoria o del phylum/division
              validacion[:taxon] = taxon
              next unless misma_categoria?
              next unless mismo_phylum?

              cuantos_encontro << taxon
            end  # End each taxones

            if cuantos_encontro.length == 0
              sin_coincidencias
            elsif cuantos_encontro.length == 1 
              sin_coincidencias
              validacion[:taxon] = cuantos_encontro.first
              self.datos[8] = 'Búsqueda similar'
              valida_extras
            else
              sin_coincidencias
              self.datos[8] = "Existe más de una búsqueda similar: #{validacion[:taxones].map{ |t| t.scat.catalogo_id }.join('|')}"
            end

          end  # End si existe mas de una busqueda exacta con multiples coincidencias

        end
      end

      bitacora.puts datos.join(',')
    end

    bitacora.close
  end

  # Arroja un hash con los datos iterados, para posteriormente guardarlos en la base
  def asigna_catalogocentralizado(archivo)
    self.datos = {}
    csv_path = Rails.root.join('log', 'validacion_IUCN', archivo)
    return unless File.exists? csv_path

    CSV.foreach(csv_path, :headers => true) do |row|
      next if SALTA_CASOS.include?(row['observaciones'])
      self.datos[row['IdCAT válido']] = { 'iucn' => [], 'sinonimos' => [] } unless datos[row['IdCAT válido']].present?
    
      # Caso mas "simple" cuando es busqueda exacta
      if row['observaciones'] == 'Búsqueda exacta'
        datos[row['IdCAT válido']]['iucn'] << CATEGORIAS_IUCN[row['Categoría en IUCN']]
      elsif row['observaciones'] == 'Búsqueda exacta y era un sinónimo'
        datos[row['IdCAT válido']]['sinonimos'] << [row['Nombre científico en IUCN'], CATEGORIAS_IUCN[row['Categoría en IUCN']]]
      end

    end
  end

  # Este proceso se corre una vez que valida_version_IUCN fue aprobado por catalogos, se vuelve a leer el archivo
  def actualiza_catalogocentralizado(archivo)
    # Borra la anterior informacion de IUCN en catalogocentralizado
    #EspecieCatalogo.where(catalogo_id: [25,26,27,28,29,30,31,32,1022,1023]).destroy_all

    #datos = {}
    #csv_path = Rails.root.join('public', 'IUCN', archivo)
    #return unless File.exists? csv_path

    #CSV.foreach(csv_path, :headers => true) do |row|
    datos.each do |dato|  
      #next if SALTA_CASOS.include?(row['observaciones'])
    
      # Caso mas "simple" cuando es busqueda exacta
      if row['mensaje'] == 'Búsqueda exacta'
        datos[row['IdCAT válido']] = { 'iucn' => '', 'observaciones' => '', 'iucn_sinonimos' => [], 'nombre valido CAT' => '' } unless datos[row['IdCAT válido']].present?
        datos[row['IdCAT válido']]['nombre valido CAT'] = row['Nombre válido CAT']
        datos[row['IdCAT válido']]['iucn'] = row['Categoría en IUCN']

        sinonimos = datos[row['IdCAT válido']]['iucn_sinonimos']
        if sinonimos.any?
          # Hubo alguna categoria de IUCN que coincidio con el sinonimo y valido, caso 2
          if (sinonimos.map{ |s| s[1] } & [row['Categoría en IUCN']]).any?
            mensaje_caso2 = "En IUCN Red List #{VERSION_IUCN} con categoría #{CATEGORIAS_IUCN[row['Categoría en IUCN']]}, como "
            mensaje_taxa_caso2 = [] 

            sinonimos.each do |sinonimo|
              if sinonimo[1] == row['Categoría en IUCN']
                mensaje_taxa_caso2 << sinonimo[0]
              end
            end

            datos[row['IdCAT válido']]['observaciones'] = mensaje_caso2 + row['Nombre válido CAT'] + ', ' + mensaje_taxa_caso2.join(', ') + '(ver relaciones de sinonimia).'
          end

          # El valido y el sinonimo tienen 2 categorias diferentes, caso 3
          if (sinonimos.map{ |s| s[1] } - [row['Categoría en IUCN']]).any?
            mensaje_caso3 = "Nombres válido y sinónimo con diferente categoría en IUCN Red List #{VERSION_IUCN}. "
            mensaje_caso3 += "#{row['Nombre válido CAT']} con categoría #{CATEGORIAS_IUCN[row['Categoría en IUCN']]}, "
            mensaje_taxa_caso3 = [] 

            sinonimos = datos[row['IdCAT válido']]['iucn_sinonimos']
            sinonimos.each do |sinonimo|
              mensaje_taxa_caso3 << "#{sinonimo[0]} con categoría #{CATEGORIAS_IUCN[sinonimo[1]]}"
            end

            if datos[row['IdCAT válido']]['observaciones'].present?
              datos[row['IdCAT válido']]['observaciones'] += mensaje_caso3 + mensaje_taxa_caso3.join(', ') + '(ver relaciones de sinonimia).'
            else
              datos[row['IdCAT válido']]['observaciones'] = mensaje_caso3 + mensaje_taxa_caso3.join(', ') + '(ver relaciones de sinonimia).'
            end
            
          end
        end

      elsif row['mensaje'] == 'Búsqueda exacta y era un sinónimo'
        if datos[row['IdCAT válido']].present?
          datos[row['IdCAT válido']]['iucn_sinonimos'] << [row['Nombre válido CAT'], row['Categoría en IUCN']]
        else
          datos[row['IdCAT válido']] = { 'iucn' => '', 'observaciones' => '', 'iucn_sinonimos' => [], 'nombre valido CAT' => '' }
          datos[row['IdCAT válido']]['iucn_sinonimos'] << [row['Nombre válido CAT'], row['Categoría en IUCN']]
          #datos[row['IdCAT válido']]['nombre valido CAT'] = row['Nombre válido CAT']
        end
      end

    end
  end


  private

  # Bitacora especial para catalogos, antes de correr en real, pasarsela
  def bitacora
    log_path = Rails.root.join('log', 'validacion_IUCN', Time.now.strftime('%Y-%m-%d_%H%m') + '_IUCN.csv')
    @@bitacora ||= File.new(log_path, 'a+')
  end

  # Comparo si el phylum/division es la misma para busquedas similares
  def mismo_phylum?
    validacion[:taxon].asigna_categorias

    if validacion[:taxon].x_reino.estandariza == 'animalia'  # Es phylum
      return true if validacion[:taxon].x_phylum.estandariza == row['phylumName'].estandariza
    else  # De lo contrario es plantae, fungi, etc
      return true if validacion[:taxon].x_division.estandariza == row['phylumName'].estandariza
    end

    self.datos[8] = 'Sin coincidencias'
    false
  end

  # Valida que la categoria taxonomica sea la misma
  def misma_categoria?
    categorias = { 'subspecies' => 'subespecie', 'subspecies-plantae' => 'subespecie', 'variety' => 'variedad' }

    categoria = if row['infraType'].blank?
                  'especie'
                else
                  categorias[row['infraType'].estandariza]
                end

    cat_taxon = validacion[:taxon].categoria_taxonomica.nombre_categoria_taxonomica.estandariza

    unless cat_taxon == categoria
      self.datos[8] = 'Sin coincidencias'
      return false
    end

    true
  end

  # Asigna el nombre valido en caso de ser un sinonimo
  def dame_el_valido
    if validacion[:taxon].estatus == 1
      if taxon_valido = validacion[:taxon].dame_taxon_valido
        validacion[:taxon] = taxon_valido
        self.datos[6] = validacion[:taxon].scat.catalogo_id
        self.datos[7] = validacion[:taxon].nombre_cientifico
        self.datos[8] = 'Búsqueda exacta y era un sinónimo'
        true
      else
        self.datos[8] = 'Es un sinónimo y hubo problemas al encontrar el válido'
        false
      end

    else
      self.datos[6] = validacion[:taxon].scat.catalogo_id
      self.datos[7] = validacion[:taxon].nombre_cientifico
      true
    end
  end

  # Valida el nombre y categoría taxonomica
  def valida_extras
    return false unless misma_categoria?
    return false unless mismo_phylum?

    self.datos[3] = validacion[:taxon].nombre_cientifico
    self.datos[4] = validacion[:taxon].scat.catalogo_id
    self.datos[5] = validacion[:taxon].estatus == 2 ? 'Válido/Aceptado' : 'Sinónimo'

    return true if ['Búsqueda similar'].include?(datos[8])
    return dame_el_valido if ['Búsqueda exacta', 'Existe más de una búsqueda exacta'].include?(datos[8])
  end

  def sin_coincidencias
    self.datos[3] = nil
    self.datos[4] = nil
    self.datos[5] = nil
    self.datos[6] = nil
    self.datos[7] = nil
    self.datos[8] = 'Sin coincidencias'
  end

  # Pasar solo una parte relativa del endpoint
  def consulta_api(endpoint)
    @iucn = CONFIG.iucn.api
    @token = CONFIG.iucn.token
    url = "#{@iucn}/#{endpoint}?token=#{@token}"

    begin
      uri = URI.escape(url)
      resp = RestClient.get uri
      jres = JSON.parse(resp)

      if jres["result"].any?
        self.datos = { estatus: true, resultado: jres["result"][0] }
      else
        self.datos = { estatus: false, msg: 'No hubo resultados' }
      end
      
    rescue => e
      self.datos = { estatus: false, msg: e }
    end
  end

end

