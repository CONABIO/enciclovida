class ValidacionesController < ApplicationController
  # Estas validaciones son los records que provienen desde SQL Server directamente (MS Access), ademas
  # de las validaciones de los archivos en excel, csv o taxones que copien y peguen en la caseta de texto

  # El request sigue siendo inseguro, hasta no poder hacer la conexion con un webservice con WSDL
  # desde SQL Server

  #Quita estos metodos para que pueda cargar correctamente la peticion
  skip_before_filter  :verify_authenticity_token, :set_locale, only: [:update, :insert, :delete]
  before_action :authenticate_request!, only: [:update, :insert, :delete]
  layout false, only: [:update, :insert, :delete]

  def update
    if params[:tabla] == 'especies'
      EspecieBio.delay.actualiza(params[:id], params[:base], params[:tabla])
    else
      Bases.delay.update_en_volcado(params[:id], params[:base], params[:tabla])
    end
    render :text => 'Datos de UPDATE correctos'
  end

  def insert
    if params[:tabla] == 'especies'
      EspecieBio.delay.completa(params[:id], params[:base], params[:tabla])
    else
      Bases.delay.insert_en_volcado(params[:id], params[:base], params[:tabla])
    end
    render :text => 'Datos de INSERT correctos'
  end

  def delete
    Bases.delay.delete_en_volcado(params[:id], params[:base], params[:tabla])
    render :text => 'Datos de DELETE correctos'
  end

  def taxon
  end

  # Validacion de taxones por medio de un csv o a traves de web
  def resultados_taxon_simple
    return @match_taxa= 'Por lo menos debe haber un taxón o un archivo' unless params[:lote].present? || params[:batch].present?

    if params[:lote].present?
      @match_taxa = Hash.new
      params[:lote].split("\r\n").each do |linea|
        e= Especie.where("nombre_cientifico = '#{linea}'")       #linea de SQL Server

        if e.first
          @match_taxa[linea] = e
        else
          ids = FUZZY_NOM_CIEN.find(linea, 3)
          coincidencias = ids.present? ? Especie.where("especies.id IN (#{ids.join(',')})").order('nombre_cientifico ASC') : nil
          @match_taxa[linea] = coincidencias.length > 0 ? coincidencias : 'Sin coincidencia'
        end
      end
    elsif params[:batch].present?
      validaBatch(params[:batch])

    end
    #@match_taxa = @match_taxa ? errores.join(' ') : 'Los datos fueron procesados correctamente'
  end

  # Validacion a traves de un excel .xlsx
  def resultados_taxon_excel
    @errores = []
    uploader = ArchivoUploader.new

    begin
      content_type = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'

      if params[:excel].content_type != content_type
        @errores << t('errors.messages.extension_validacion_excel')
      else
        xlsx = Roo::Excelx.new(params[:excel].path, nil, :ignore)
        @sheet = xlsx.sheet(0)  # toma la primera hoja por default

        rows = @sheet.last_row - @sheet.first_row  # Para quietarle del conteo la cabecera
        columns = @sheet.last_column

        @errores << 'La primera hoja de tu excel no tiene información' if rows < 0
        @errores << 'Las columnas no son las mínimas necesarias para poder leer tu excel' if columns < 7

        if @errores.empty?
          cabecera = @sheet.row(1)
          cc = comprueba_columnas(cabecera)

          # Por si no cumple con las columnas obligatorias
          if cc[:faltan].any?
            @errores << "Algunas columnas obligatorias no fueron encontradas en tu excel: #{cc[:faltan].join(', ')}"
          else
            uploader.store!(params[:excel])  # Guarda el archivo
            valida_campos(@sheet, cc[:asociacion])  # Valida los campos en la base
          end
        end
      end  # Fin del tipo de archivo

    rescue CarrierWave::IntegrityError => c
      @errores << c
    end  # Fin del rescue
  end

  private

  def asigna_categorias_correspondientes(taxon)
    return nil unless taxon.ancestry_ascendente_directo.present?  # Por si se les olvido poner el ascendente_directo o es reino
    ids = taxon.ancestry_ascendente_directo.gsub('/',',')

    Especie.select('nombre, nombre_categoria_taxonomica').categoria_taxonomica_join.caso_rango_valores('especies.id',ids).each do |ancestro|
      categoria = 'x_' << I18n.transliterate(ancestro.nombre_categoria_taxonomica).gsub(' ','_').downcase
      next unless Lista::COLUMNAS_CATEGORIAS.include?(categoria)
      eval("taxon.#{categoria} = ancestro.nombre")  # Asigna el nombre del ancestro si es que coincidio con la categoria

      # Asigna autoridades para el excel
      if categoria == 'x_especie'
        taxon.x_nombre_autoridad_especie = taxon.nombre_autoridad
      end

      # Para las infraespecies
      infraespecies = CategoriaTaxonomica::CATEGORIAS_INFRAESPECIES.map{|c| "x_#{c}"}
      if infraespecies.include?(categoria)
        taxon.x_nombre_autoridad_infraespecie = taxon.nombre_autoridad
      end
    end

    # Asigna la categoria taxonomica
    taxon.x_categoria_taxonomica = taxon.categoria_taxonomica.nombre_categoria_taxonomica
    taxon
  end

  # Si concidio mas de uno, busca recursivamente arriba de genero (familia) para ver el indicado
  def busca_recursivamente(taxones, hash)
    coincidio_alguno = false
    taxon_coincidente = Especie.none
    nombres = hash['nombre_cientifico'].split(' ')
    h = hash

    taxones.each do |t|  # Iterare cada taxon que resulto parecido para ver cual es el correcto
      t = asigna_categorias_correspondientes(t)
      next unless t.present?  # Por si regresa nulo

      # Si es la especie lo mando directo a coincidencia
      cat_tax_taxon_cat = I18n.transliterate(t.x_categoria_taxonomica).gsub(' ','_').downcase
      if cat_tax_taxon_cat == 'especie' && nombres.length == 2 && hash[:infraespecie].blank?
        return {taxon: t, hash: h, estatus: true}
      end

      # Comparamos entonces la familia, si vuelve a coincidir seguro existe un error en catalogos
      if t.x_familia == hash['familia'].downcase

        if coincidio_alguno
          return {hash: h, estatus: false, error: 'Existen 2 taxones iguales, coinciden hasta familias'}
        else
          taxon_coincidente = t
          coincidio_alguno = true
        end
      end
    end  #Fin each taxones coincidentes

    # Mando el taxon si coincidio alguno
    if coincidio_alguno
      return {taxon: taxon_coincidente, hash: h, estatus: true}
    else  # De lo contrario no hubo coincidencias claras
      return {hash: h, estatus: false, error: 'Existen 2 taxones iguales, coinciden hasta familias'}
    end
  end

  # Encuentra el mas parecido
  def encuentra_record_por_nombre_cientifico(hash = {})
    # Evita que el nombre cientifico este vacio
    if hash['nombre_cientifico'].blank?
      return {hash: h, estatus: false, error: 'El nombre cientifico está vacío'}
    end

    h = hash
    taxon = Especie.where(nombre_cientifico: hash['nombre_cientifico'])

    if taxon.length == 1  # Caso mas sencillo, coincide al 100 y solo es uno
      return {taxon: taxon.first, hash: hash, estatus: true}

    elsif taxon.length > 1  # Encontro el mismo nombre cientifico mas de una vez
      return busca_recursivamente(taxon, hash)

    else
      # Parte de expresiones regulares a ver si encuentra alguna coincidencia
      nombres = hash['nombre_cientifico'].split(' ')

      taxon = if nombres.length == 2  # Especie
                Especie.where("nombre_cientifico LIKE '#{nombres[0]} %#{nombres[1]}'")
              elsif nombres.length == 3  # Infraespecie
                Especie.where("nombre_cientifico LIKE '#{nombres[0]} %#{nombres[1]} %#{nombres[2]}'")
              elsif nombres.length == 1 # Genero o superior
                Especie.where("nombre_cientifico LIKE '#{nombres[0]}'")
              end

      if taxon.length == 1  # Caso mas sencillo
        return {taxon: taxon.first, hash: hash, estatus: true}
      elsif taxon.length > 1
        return busca_recursivamente(taxon, hash)
      else  # Lo buscamos con el fuzzy match y despues con el algoritmo de aproximacion
        ids = FUZZY_NOM_CIEN.find(hash['nombre_cientifico'], limit=CONFIG.limit_fuzzy)

        if ids.present?
          taxones = Especie.caso_rango_valores('especies.id', ids.join(','))

          if taxones.empty?
            return {hash: h, estatus: false, error: 'Sin coincidencias'}
          end

          taxones_con_distancia = []
          taxones.each do |taxon|
            # Si la distancia entre palabras es menor a 3 que muestre la sugerencia
            distancia = Levenshtein.distance(hash['nombre_cientifico'].downcase, taxon.nombre_cientifico.limpiar.downcase)

            next if distancia > 2  # No cumple con la distancia
            taxones_con_distancia << taxon
          end

          if taxones_con_distancia.empty?
            return {hash: h, estatus: false, error: 'Sin coincidencias'}
          else
            return busca_recursivamente(taxones_con_distancia, hash)
          end

        else  # No hubo coincidencias con su nombre cientifico
          return {hash: h, estatus: false, error: 'Sin coincidencias'}
        end
      end

    end  #Fin de las posibles coincidencias
  end

  def valida_campos(sheet, asociacion)
    @hash = []
    primera_fila = true

    puts asociacion.inspect
    #sheet.parse(:clean => true)  # Para limpiar los caracteres de control y espacios en blanco de mas
    sheet.parse(asociacion).each do |hash|
      if primera_fila
        primera_fila = false
        next
      end

      info = encuentra_record_por_nombre_cientifico(hash)

      if info[:estatus]
        @hash << info[:hash].merge(nombre_cientifico_cat: info[:taxon].nombre_cientifico)
      else
        @hash << info[:hash]
      end
    end
  end

  # Asocia la respuesta para armar el contenido del excel
  def asocia_respuesta(info = {})
    if info[:estatus]
      taxon = info[:taxon]
      hash = info

      if taxon.estatus == 1  # Si es sinonimo, asocia el nombre_cientifico valido
        estatus = taxon.especies_estatus     # Checa si existe alguna sinonimia

        if estatus.length == 1  # Encontro el valido y solo es uno, como se esperaba
          begin  # Por si ya no existe ese taxon, suele pasar!
            taxon_valido = Especie.find(estatus.especie_id2)
            t_val = asigna_categorias_correspondientes(taxon_valido)  # Le asociamos los datos
            hash[:taxon_valido] = t_val
          rescue
            hash[:estatus] = false
            hash[:error] = 'No existe el taxón válido en CAT'
          end

        else  # No existe el valido >.>!
          hash[:estatus] = false
          hash[:error] = 'No existe el taxón válido en CAT'
        end
      end  # End estatus = 1
    end  # End info estatus

    # Se completa cada seccion del excel
    resumen_hash = resumen(hash)
    correcciones_hash = correcciones(hash)
  end

  # Parte roja del excel
  def resumen(info = {})
    resumen_hash = {}

    if info[:estatus]
      taxon = info[:taxon]
      hash = info[:hash]

      resumen_hash['SCAT_NombreEstatus'] = Especie::ESTATUS_SIGNIFICADO[taxon.estatus]
      resumen_hash['SCAT_Observaciones'] = nil
      resumen_hash['SCAT_Correccion_NombreCient'] = taxon.nombre_cientifico.downcase == hash['nombre_cientifico'].downcase ? nil : taxon.nombre_cientifico
      resumen_hash['SCAT_NombreCient_valido'] = info[:taxon_valido].present? ? info[:taxon_valido].nombre_cientifico : taxon.nombre_cientifico
      resumen_hash['SCAT_Autoridad_NombreCient_valido'] = info[:taxon_valido].present? ? info[:taxon_valido].nombre_autoridad : taxon.nombre_autoridad

    else  # Asociacion vacia, solo el error
      resumen_hash['SCAT_NombreEstatus'] = nil
      resumen_hash['SCAT_Observaciones'] = info[:error]
      resumen_hash['SCAT_Correccion_NombreCient'] = nil
      resumen_hash['SCAT_NombreCient_valido'] = nil
      resumen_hash['SCAT_Autoridad_NombreCient_valido'] = nil
    end

    resumen_hash
  end

  # Parte azul del excel
  def correcciones(info = {})
    correcciones_hash = {}

    if info[:estatus]
      taxon = info[:taxon]
      hash = info[:hash]

      if hash.key?('reino')
        correcciones_hash['SCAT_CorreccionReino'] = taxon.x_reino.downcase == hash['reino'].downcase ? nil : taxon.x_reino
      end

      if hash.key?('division')
        correcciones_hash['SCAT_CorreccionDivision'] = taxon.x_division.downcase == hash['division'].downcase ? nil : taxon.x_division
      end

      if hash.key?('subdivision')
        correcciones_hash['SCAT_CorreccionSubdivision'] = taxon.x_subdivision.downcase == hash['subdivision'].downcase ? nil : taxon.x_subdivision
      end

      if hash.key?('phylum')
        correcciones_hash['SCAT_CorreccionPhylum'] = taxon.x_phylum.downcase == hash['phylum'].downcase ? nil : taxon.x_phylum
      end

      if hash.key?('clase')
        correcciones_hash['SCAT_CorreccionClase'] = taxon.x_clase.downcase == hash['clase'].downcase ? nil : taxon.x_clase
      end

      if hash.key?('subclase')
        correcciones_hash['SCAT_CorreccionSubclase'] = taxon.x_subclase.downcase == hash['subclase'].downcase ? nil : taxon.x_subclase
      end

      if hash.key?('orden')
        correcciones_hash['SCAT_CorreccionOrden'] = taxon.x_orden.downcase == hash['orden'].downcase ? nil : taxon.x_orden
      end

      if hash.key?('suborden')
        correcciones_hash['SCAT_CorreccionSuborden'] = taxon.x_suborden.downcase == hash['suborden'].downcase ? nil : taxon.x_suborden
      end

      if hash.key?('infraorden')
        correcciones_hash['SCAT_CorreccionInfraorden'] = taxon.x_infraorden.downcase == hash['infraorden'].downcase ? nil : taxon.x_infraorden
      end

      if hash.key?('superfamilia')
        correcciones_hash['SCAT_CorreccionSuperfamilia'] = taxon.x_superfamilia.downcase == hash['superfamilia'].downcase ? nil : taxon.x_superfamilia
      end

      if hash.key?('familia')
        correcciones_hash['SCAT_CorreccionFamilia'] = taxon.x_familia.downcase == hash['familia'].downcase ? nil : taxon.x_familia
      end

      if hash.key?('genero')
        correcciones_hash['SCAT_CorreccionGenero'] = taxon.x_genero.downcase == hash['genero'].downcase ? nil : taxon.x_genero
      end

      if hash.key?('subgenero')
        correcciones_hash['SCAT_CorreccionSubgenero'] = taxon.x_subgenero.downcase == hash['subgenero'].downcase ? nil : taxon.x_subgenero
      end

      if hash.key?('especie')
        correcciones_hash['SCAT_CorreccionEspecie'] = taxon.x_especie.downcase == hash['especie'].downcase ? nil : taxon.x_especie
      end

      if hash.key?('autoridad')
        correcciones_hash['SCAT_CorreccionAutorEspecie'] = taxon.x_nombre_autoridad_especie.downcase == hash['autoridad'].downcase ? nil : taxon.x_nombre_autoridad_especie
      end

      if hash.key?('infraespecie')
        cat = I18n.transliterate(taxon.x_categoria_taxonomica).gsub(' ','_').downcase

        if CategoriaTaxonomica::CATEGORIAS_INFRAESPECIES.include?(cat)
          correcciones_hash['SCAT_CorreccionInfraespecie'] = taxon.nombre.downcase == hash['infraespecie'].downcase ? nil : taxon.nombre
        else
          correcciones_hash['SCAT_CorreccionInfraespecie'] = nil
        end
      end

      if hash.key?('autoridad_infraespecie')
        correcciones_hash['SCAT_CorreccionAutorInfraespecie'] = taxon.x_nombre_autoridad_infraespecie.downcase == hash['autoridad_infraespecie'].downcase ? nil : taxon.x_nombre_autoridad_infraespecie
      end

      # correcciones_hash['SCAT_CorreccionSinonimo'] = ''  # Sin implementar

    else  # Asociacion vacia
        correcciones_hash['SCAT_CorreccionReino'] = nil if hash.key?('reino')
        correcciones_hash['SCAT_CorreccionDivision'] = nil if hash.key?('division')
        correcciones_hash['SCAT_CorreccionSubdivision'] = nil if hash.key?('subdivision')
        correcciones_hash['SCAT_CorreccionPhylum'] = nil if hash.key?('phylum')
        correcciones_hash['SCAT_CorreccionClase'] = nil if hash.key?('clase')
        correcciones_hash['SCAT_CorreccionSubclase'] = nil if hash.key?('subclase')
        correcciones_hash['SCAT_CorreccionOrden'] = nil if hash.key?('orden')
        correcciones_hash['SCAT_CorreccionSuborden'] = nil if hash.key?('suborden')
        correcciones_hash['SCAT_CorreccionInfraorden'] = nil if hash.key?('infraorden')
        correcciones_hash['SCAT_CorreccionSuperfamilia'] = nil if hash.key?('superfamilia')
        correcciones_hash['SCAT_CorreccionFamilia'] = nil if hash.key?('familia')
        correcciones_hash['SCAT_CorreccionGenero'] = nil if hash.key?('genero')
        correcciones_hash['SCAT_CorreccionSubgenero'] = nil if hash.key?('subgenero')
        correcciones_hash['SCAT_CorreccionEspecie'] = nil if hash.key?('especie')
        correcciones_hash['SCAT_CorreccionAutorEspecie'] = nil if hash.key?('autoridad')
        correcciones_hash['SCAT_CorreccionInfraespecie'] = nil if hash.key?('infraespecie')
        correcciones_hash['SCAT_CorreccionAutorInfraespecie'] = nil if hash.key?('autoridad_infraespecie')
    end

    correcciones_hash
  end

  def validacion_interna(info = {})

  end

  def comprueba_columnas(cabecera)
    columnas_obligatoraias = %w(familia genero especie autoridad infraespecie categoria nombre_cientifico)
    columnas_opcionales = %w(division subdivision clase subclase orden suborden infraorden superfamilia autoridad_infraespecie)
    columnas_asociadas = Hash.new
    columnas_faltantes = []

    cabecera.each do |c|
      next unless c.present?  # para las cabeceras vacias
      cab = I18n.transliterate(c).gsub(' ','_').gsub('-','_').downcase

      if columnas_obligatoraias.include?(cab) || columnas_opcionales.include?(cab)
        columnas_obligatoraias.delete(cab) if columnas_obligatoraias.include?(cab)

        # Se hace con regexp porque por default agarra las similiares, ej: Familia y Superfamilia (toma la primera)
        columnas_asociadas[cab] = "^#{c}$"
      end
    end

    columnas_obligatoraias.compact.each do |col_obl|
      columnas_faltantes << t("columnas_obligatorias_excel.#{col_obl}")
    end

    {faltan: columnas_faltantes, asociacion: columnas_asociadas}
  end

  def authenticate_request!
    return nil unless CONFIG.ip_sql_server.include?(request.remote_ip)
    return nil unless params[:secret] == CONFIG.secret_sql_server.to_s.parameterize
    return nil if params[:id].blank? || params[:base].blank? || params[:tabla].blank?
    return nil unless CONFIG.bases.include?(params[:base])
    return nil unless Bases::EQUIVALENCIA.include?(params[:tabla])
  end
end