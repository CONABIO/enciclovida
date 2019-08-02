class BusquedaRegion < Busqueda
  attr_accessor :resp, :key_especies, :key_especies_con_filtro, :url_especies

  # Esta correspondencia no deberia existir pero las regiones en el snib las hicieron con las patas
  CORRESPONDENCIA = [nil, '08', '01', '07', '23', '26', '10', '32', '16', '13', '24', '25', '04',
                     '06', '31', '12', '20', '18', '14', '02', '19', '21', '15', '27', '03', '11',
                     '22', '30', '05', '28', '09', '29', '17']

  # REVISADO: Cache para obtener el conteo de especies por grupo
  def cache_conteo_por_grupo
    if params[:tipo_region].present?
      correspondencia_estado
      return unless resp[:estatus]

      if params[:estado_id].present? && params[:municipio_id].present?
        key = "conteo_grupo_#{params[:tipo_region]}_#{params[:estado_id]}_#{params[:municipio_id]}"
        url = "#{CONFIG.ssig_api}/taxonMuni/listado/total/#{params[:estado_id]}/#{params[:municipio_id].rjust(3,'0')}?apiKey=enciclovida"
      elsif params[:estado_id].present?
        key = "conteo_grupo_#{params[:tipo_region]}_#{params[:estado_id]}"
        url = "#{CONFIG.ssig_api}/taxonEdo/conteo/total/#{params[:estado_id]}?apiKey=enciclovida"
      else
        return self.resp = { estatus: false, msg: 'Los parametros no son correctos.' }
      end

      self.resp = Rails.cache.fetch(key, expires_in: eval(CONFIG.cache.busquedas_region.conteo_grupo)) do
        respuesta_conteo_por_grupo(url)
      end

    else
      self.resp = { estatus: false, msg: "El parámetro 'tipo_region' esta vacío." }
    end
  end

  # Verifica si esta la llave con filtros primero, de lo contrario hace los pasos para obtenerla
  def especies_por_grupo
    existe_cache_especies_por_grupo_con_filtros?

    if resp[:estatus]  # Para ver si los parametros son correctos
      if resp[:key]  # Para ver si la llave existe
        cache_especies_por_grupo_con_filtros
      else
        cache_especies_por_grupo
        cache_especies_por_grupo_con_filtros
      end  # End key

      # Esta consulta no va en el cache para poder manejarla de mi aldo y sea mas rapida la respuesta
      filtro_con_nombre
    end  # End resp[:estatus]
  end

  def cache_especies_por_grupo
    self.resp = Rails.cache.fetch(key_especies, expires_in: eval(CONFIG.cache.busquedas_region.especies_grupo)) do
      respuesta_especies_por_grupo(url_especies)
    end
  end

  # Es la busqueda con los filtros, regio y grupo de la busqueda por region
  def cache_especies_por_grupo_con_filtros
    self.resp = Rails.cache.fetch(key_especies_con_filtro, expires_in: eval(CONFIG.cache.busquedas_region.especies_grupo)) do
      # Una vez obtenida la respuesta del servicio o del cache iteramos en la base
      if resp[:estatus]
        especies_hash = {}

        resp[:resultados].each do |r|
          especies_hash[r['idnombrecatvalido']] = r['nregistros'].to_i
        end
        especies_hash = especies_hash.sort_by {|key, value| value}.reverse.to_h

        filtros_default(especies_hash.keys)  # Hace el query con los filtros default
        resultados = taxones.map{|taxon| {id: taxon.id, nombre_cientifico: taxon.nombre_cientifico, catalogo_id: taxon.catalogo_id, nombre_comun: taxon.nombre_comun_principal, foto: taxon.foto_principal}}

        resultados.each do |taxon|
          especies_hash[taxon[:catalogo_id]] = taxon.merge({nregistros: especies_hash[taxon[:catalogo_id]]})
        end

        # Para dejar solo lo que coincidio con la consulta
        especies_hash = especies_hash.map{|k, v| v if v.class == Hash}

        {estatus: true, resultados: especies_hash.compact}
      else
        resp
      end
    end
  end


  private

  # REVISADO: Consulta el conteo por especie en el servicio de Abraham
  def respuesta_conteo_por_grupo(url)
    begin
      rest = RestClient.get(url)
      conteo = JSON.parse(rest)

      if conteo.kind_of?(Hash) && conteo['error'].present?
        {estatus: false, msg: conteo['error']}
      else
        conteo = icono_grupo(conteo)
        {estatus: true, resultados: conteo}
      end
    rescue => e
      {estatus: false, msg: e.message}
    end
  end

  def respuesta_especies_por_grupo(url)
    begin
      rest = RestClient.get(url)
      especies = JSON.parse(rest)

      {estatus: true, resultados: especies}

    rescue => e
      {estatus: false, msg: e.message}
    end
  end

  # Para saber si la peticion con la region y los filtros ya existe y consultar directo cache especies_por_grupo
  def existe_cache_especies_por_grupo_con_filtros?
    if params[:grupo].present? && params[:tipo_region].present?
      correspondencia_estado
      return unless resp[:estatus]

      if params[:estado_id].present? && params[:municipio_id].present?
        self.key_especies = "especies_grupo_#{params[:tipo_region]}_#{params[:grupo].estandariza}_#{params[:estado_id]}_#{params[:municipio_id]}"
        self.url_especies = "#{CONFIG.ssig_api}/taxonMuni/listado/#{params[:estado_id]}/#{params[:municipio_id].rjust(3, '0')}/edomun/#{params[:grupo].estandariza}?apiKey=enciclovida"
      elsif params[:estado_id].present?
        self.key_especies = "especies_grupo_#{params[:tipo_region]}_#{params[:grupo].estandariza}_#{params[:estado_id]}"
        self.url_especies = "#{CONFIG.ssig_api}/taxonEdo/conteo/#{params[:estado_id]}/edomun/#{params[:grupo].estandariza}?apiKey=enciclovida"
      else
        return self.resp = { estatus: false, msg: 'Los parametros no son correctos.' }
      end

      # La llave con los diferentes filtros
      edo_cons = params[:edo_cons].present? ? params[:edo_cons].join('-') : ''
      dist = params[:dist].present? ? params[:dist].join('-') : ''
      prior = params[:prior].present? ? params[:prior].join('-') : ''
      self.key_especies_con_filtro = "#{key_especies}_#{edo_cons}_#{dist}_#{prior}".estandariza
      self.resp = {estatus: true, key: Rails.cache.exist?(self.key_especies_con_filtro)}
    else
      self.resp = {estatus: false, msg: "Por favor verifica tus parámetros, 'grupo' y 'tipo_region' son obligatorios"}
    end
  end

  def filtro_con_nombre
    if params[:nombre].present?
      if resp[:estatus]
        self.resp[:resultados] = resp[:resultados].map{|t| t if (/#{params[:nombre].sin_acentos}/.match(t[:nombre_cientifico].sin_acentos) || /#{params[:nombre].sin_acentos}/.match(t[:nombre_comun].try(:sin_acentos)))}.compact
      end
    end
  end

  def filtros_default(ids)
    self.taxones = taxones.select(:id, :nombre_cientifico).select("nombre_comun_principal, foto_principal, #{Scat.attribute_alias(:catalogo_id)} AS catalogo_id").where("#{Scat.attribute_alias(:catalogo_id)} IN (?)", ids)
    tipo_distribucion
    estado_conservacion
  end

  # Asigna el grupo iconico de enciclovida de acuerdo nombres y grupos del SNIB
  def icono_grupo(grupos)
    grupos.each do |g|

      case g['grupo']
        when 'Anfibios'
          g.merge!({'icono' => 'amphibia-ev-icon', 'reino' => 'animalia'})
        when 'Aves'
          g.merge!({'icono' => 'aves-ev-icon', 'reino' => 'animalia'})
        when 'Bacterias'
          g.merge!({'icono' => 'prokaryotae-ev-icon', 'reino' => 'prokaryotae'})
        when 'Hongos'
          g.merge!({'icono' => 'fungi-ev-icon', 'reino' => 'fungi'})
        when 'Invertebrados'
          g.merge!({'icono' => 'invertebrados-ev-icon', 'reino' => 'animalia'})
        when 'Mamíferos'
          g.merge!({'icono' => 'mammalia-ev-icon', 'reino' => 'animalia'})
        when 'Peces'
          g.merge!({'icono' => 'actinopterygii-ev-icon', 'reino' => 'animalia'})
        when 'Plantas'
          g.merge!({'icono' => 'plantae-ev-icon', 'reino' => 'plantae'})
        when 'Protoctistas'
          g.merge!({'icono' => 'protoctista-ev-icon', 'reino' => 'protoctista'})
        when 'Reptiles'
          g.merge!({'icono' => 'reptilia-ev-icon', 'reino' => 'animalia'})
      end
    end

    grupos
  end

  # La correspondencia del estado en el servicio de Abraham, debio haber sido la llave priamria ...
  def correspondencia_estado
    valor = CORRESPONDENCIA[params[:estado_id].to_i]

    if valor
      self.params[:estado_id] = valor
      self.resp = { estatus: true }
    else
      self.resp = { estatus: false, msg: "El parámetro 'estado_id' no es es correcto." }
    end
  end
end