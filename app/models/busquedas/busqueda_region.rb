class BusquedaRegion < Busqueda

  attr_accessor :resp, :query, :idcats

  ESPECIES_POR_PAGINA = 8.freeze

  def initialize
    self.taxones = []
    self.query = []
    self.totales = 0
  end

  # Regresa un listado de especies por pagina, de acuerdo a la region y los filtros seleccionados
  def especies
    if params[:region_id].present?
      especies_por_region
      return unless resp[:estatus]

      resultados_region = resp[:resultados]  # Los resultados de los cuales saldra la respuesta (cache)

      if tiene_filtros?
        pagina_original = params[:pagina]
        self.params[:por_pagina] = 100000  # Para sacar todos los resultados de los filtros
        self.params[:pagina] = 1
        dame_especies_filtros
        return unless resp[:estatus]

        # Itera el que tengas menos registros, para más eficiencia
        if resp[:resultados].length <= resultados_region.length
          self.resp[:resultados] = resp[:resultados].delete_if{ |k,v| self.resp[:resultados][k] = resultados_region[k] if resultados_region.has_key?(k); !resultados_region.has_key?(k) }.sort_by { |k,v| v }.reverse.to_h
        else
          self.resp[:resultados] = resultados_region.delete_if{ |k,v| !resp[:resultados].has_key?(k) }
        end

        self.resp[:totales] = resp[:resultados].length
        self.params[:pagina] = pagina_original
        self.params[:por_pagina] = ESPECIES_POR_PAGINA

        dame_especies_por_pagina
        return unless resp[:estatus]

        self.totales = resp[:resultados].length
        self.resp[:resultados] = nil

      else
        dame_especies_por_pagina
        return unless resp[:estatus]

        self.totales = resp[:totales]
        self.resp[:resultados] = nil
      end

    else
      especies_por_region
      return unless resp[:estatus]
      especies_filtros
      especies_por_pagina
      asocia_informacion_taxon

      self.resp[:taxones] = taxones
      self.resp[:resultados] = nil
    end
  end

  # Consulta los querys guardados en cache o los consulta al vuelo
  def especies_por_region
    geo = Geoportal::Snib.new
    geo.tipo_region = params[:tipo_region].estandariza
    geo.region_id = params[:region_id]
    geo.especies_por_region
    self.resp = geo.resp
  end

  # Borra el cache de las especies por region
  def borra_cache_especies_por_region
    Rails.cache.delete("br_#{params[:tipo_region]}_#{params[:region_id]}") if Rails.cache.exist?("br_#{params[:tipo_region]}_#{params[:region_id]}")
  end


  private

  # Pregunta al servicio por el listado completo de las especies directo al servicio, solo consultar si no existe el cache
  def respuesta_especies_regiones(url)
    begin
      rest = RestClient::Request.execute(method: :get, url: url, timeout: 60*10)
      res = JSON.parse(rest)
      totales = res.length
      Rails.logger.debug "[DEBUG] - Hubo respuesta con: #{params.inspect}"

      if totales > 0
        return { estatus: true, resultados: res, totales: totales }
      else
        return { estatus: false, totales: totales, msg: 'No hay especies con esa busqueda' }
      end

    rescue => e
      Rails.logger.debug "[DEBUG] - Hubo un error en el servidor con: #{params.inspect} - #{e.message}"
      { estatus: false, msg: e.message }
    end
  end

  # REVISADO: Regresa la busqueda avanzada
  def especies_filtros
    return unless tiene_filtros?
    self.taxones = Especie.select(:id).select("#{Scat.attribute_alias(:catalogo_id)}").joins(:scat).distinct

    #paginado_y_offset
    estatus
    #solo_publicos
    estado_conservacion
    tipo_distribucion
    uso
    #ambiente
    #region
  end

  # Una vez leyendo la lista del cache, le aplico los filtros que el usuario haya escogido
  def dame_especies_filtros
    # Para la nom, iucn o cites
    if params[:edo_cons].present? && params[:edo_cons].any?
      params[:edo_cons] = params[:edo_cons].map(&:to_i)

      # Para la NOM
      nom_ids = Catalogo.nom.map(&:id) & params[:edo_cons]
      self.query << "nom=#{nom_ids.to_s}" if nom_ids.any?

      # Para IUCN
      iucn_ids = Catalogo.iucn.map(&:id) & params[:edo_cons]
      self.query << "iucn=#{iucn_ids.to_s}" if iucn_ids.any?

      # Para CITES
      cites_ids = Catalogo.cites.map(&:id) & params[:edo_cons]
      self.query << "cites=#{cites_ids.to_s}" if cites_ids.any?
    end

    # Para los grupos iconicos
    self.query << "grupo=#{URI::encode(params[:grupo].to_s)}" if params[:grupo].present? && params[:grupo].any?

    # Para el tipo de distribucion
    if params[:dist].present? && params[:dist].any?
      params[:dist] = params[:dist].map(&:to_i)
      distribucion_ids = params[:dist] & TipoDistribucion.distribuciones_vista_general.map(&:id)
      self.query << "dist=#{distribucion_ids.to_s}" if distribucion_ids.any?
    end

    # Por si es la primera pagina con o sin filtros
    if params[:pagina].to_i == 1
      respuesta_especies_filtros_conteo
      return self.resp = { estatus: false } unless resp[:estatus]
    end

    # El paginado
    self.query << "pagina=#{params[:pagina] || 1}"
    self.query << "por_pagina=#{params[:por_pagina] || ESPECIES_POR_PAGINA}"

    respuesta_especies_filtros
  end

  # Regresa las especies del servicio de /especies/region/filtros
  def respuesta_especies_filtros
    url_especies = "#{CONFIG.enciclovida_api}/especies/region/filtros?#{query.join('&')}"

    begin
      rest = RestClient.get(url_especies)
      resultados = JSON.parse(rest)
    rescue => e
      return self.resp = { estatus: false, msg: e.message }
    end

    self.resp = if resp.present?
                  resp.merge({ estatus: true, resultados: resultados })
                else
                  { estatus: true, resultados: resultados }
                end
  end

  # Regresa el conteo de especies del servicio de /especies/region/filtros
  def respuesta_especies_filtros_conteo
    url_conteo = "#{CONFIG.enciclovida_api}/especies/region/filtros/conteo?#{query.join('&')}"

    begin
      rest = RestClient.get(url_conteo)
      resultados = JSON.parse(rest)
    rescue => e
      return self.resp = { estatus: false, msg: e.message }
    end

    if resultados['nespecies'] > 0
      self.resp = { estatus: true, totales: resultados['nespecies'] }
    else
      self.resp = { estatus: false, msg: 'No existe ningun resultado con esos filtros. Intenta cambiando los filtros.' }
    end
  end

  # Asocia la información a desplegar en la vista, iterando los resultados
  def asocia_informacion_taxon
    return unless (resp[:resultados].present? && resp[:resultados].any?)
    self.taxones = []
    especies = Especie.select_basico(["#{Scat.attribute_alias(:catalogo_id)} AS catalogo_id"]).left_joins(:categoria_taxonomica, :adicional, :scat).where("#{Scat.attribute_alias(:catalogo_id)} IN (?)", resp[:resultados].keys)

    especies.each do |especie|
      self.taxones << { especie: especie, nregistros: resp[:resultados][especie.catalogo_id] }

      if params[:region_id].present? && params[:tipo_region].present?
        self.taxones.last.merge!({ snib_registros: "#{CONFIG.enciclovida_api}/especie/snib/ejemplares?idnombrecatvalido=#{especie.catalogo_id}&region_id=#{params[:region_id]}&tipo_region=#{params[:tipo_region]}&mapa=true" })
      else
        carpeta = Rails.root.join('public', 'geodatos', especie.id.to_s)
        nombre = carpeta.join("ejemplares_#{especie.nombre_cientifico.limpiar.gsub(' ','_')}_mapa")
        archivo = "#{nombre}.json"
        archivo_url = "#{CONFIG.site_url}geodatos/#{especie.id}/#{"ejemplares_#{especie.nombre_cientifico.limpiar.gsub(' ','_')}_mapa.json"}"

        next unless File.exist?(archivo)
        self.taxones.last.merge!({ snib_registros: archivo_url })
      end
    end

    self.taxones = taxones.sort_by{ |t| t[:nregistros] }.reverse
  end

  # Regresa true or false
  def tiene_filtros?
    (params[:grupo].present? && params[:grupo].any?) || (params[:dist].present? && params[:dist].any?) || (params[:edo_cons].present? && params[:edo_cons].present?)
  end

  # Las especies por pagina cuando escogio una region
  def dame_especies_por_pagina
    self.por_pagina = params[:por_pagina] || ESPECIES_POR_PAGINA
    self.pagina = params[:pagina].present? ? params[:pagina].to_i : 1

    return unless resp[:estatus]

    if keys = resp[:resultados].keys[(por_pagina*pagina-por_pagina)..por_pagina*pagina-1]
      especies = {}

      keys.each do |k|
        especies[k] = resp[:resultados][k]
      end

      self.resp[:resultados] = especies
      asocia_informacion_taxon
      self.resp[:taxones] = taxones

    else
      self.resp[:estatus] = false
      self.resp[:msg] = 'No hay más especies'
    end
  end

  # Devuelve las especies de acuerdo al numero de pagina y por pagina definido
  def especies_por_pagina
    return unless resp[:estatus]
    self.por_pagina = params[:por_pagina] || ESPECIES_POR_PAGINA
    self.pagina = params[:pagina].present? ? params[:pagina].to_i : 1
    offset = (pagina-1)*por_pagina
    limit = (pagina*por_pagina)-1

    if taxones.any?  # Quiere decir que tuvo algun filtro
      ids = taxones.map(&:catalogo_id) & resp[:resultados].keys
      idcats = resp[:resultados].delete_if { |k,v| !ids.include?(v) }.to_a
    else  # Es la pagina inicial de busquedas por region
      idcats = resp[:resultados].to_a
    end
    
    self.resp[:resultados] = idcats[offset..limit].to_h
  end

end