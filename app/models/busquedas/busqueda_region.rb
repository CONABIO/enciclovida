class BusquedaRegion < Busqueda

  attr_accessor :resp, :query

  ESPECIES_POR_PAGINA = 10.freeze

  def initialize
    self.taxones = []
    self.query = []
    self.totales = 0
  end

  # Regresa un listado de especies por pagina, de acuerdo a la region y los filtros seleccionados
  def especies
    if params[:region_id].present?
      dame_especies_regiones
      return unless resp[:estatus]
      resultados_region = resp[:resultados]  # Los resultados de los caules saldra la respuesta (cache)

      if tiene_filtros?
        self.params[:por_pagina] = 100000
        dame_especies_filtros

        if resp[:estatus]
          resultados_filtros = resp[:resultados].map { |k,v| k['idnombrecatvalido'] }
          self.resp[:resultados] = resultados_region.map { |k,v| { 'idnombrecatvalido' => k['idnombrecatvalido'], 'nregistros' => k['nregistros'] } if resultados_filtros.include?(k['idnombrecatvalido']) }.compact
          self.resp[:totales] = resp[:resultados].length

          dame_especies_por_pagina
          self.resp[:resultados] = nil
        end
      else
        dame_especies_por_pagina
        self.resp[:resultados] = nil
      end

    else
      dame_especies_filtros

      if resp[:estatus]
        asocia_informacion_taxon
        resp[:taxones] = taxones
        self.resp[:resultados] = nil
      end
    end
  end

  # Consulta los querys guardados en cache o los consulta al vuelo
  def dame_especies_regiones
    self.resp = Rails.cache.fetch("especies_#{params[:tipo_region]}_#{params[:region_id]}", expires_in: eval(CONFIG.cache.busquedas_region)) do
      url = "#{CONFIG.enciclovida_api}/especies/#{params[:tipo_region]}/#{params[:region_id]}"
      respuesta_especies_regiones(url)
    end
  end

  # Borra el cache de las especies por region
  def borra_cache_especies_regiones
    Rails.cache.delete("especies_#{params[:tipo_region]}_#{params[:region_id]}") if Rails.cache.exist?("especies_#{params[:tipo_region]}_#{params[:region_id]}")
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
    respuesta_especies_filtros_conteo if params[:pagina].to_i == 1

    if resp[:estatus]
      respuesta_especies_filtros
    else
      self.resp = { estatus: false }
    end
  end

  # Regresa las especies del servicio de /especies/filtros
  def respuesta_especies_filtros
    # El paginado
    self.query << "pagina=#{params[:pagina]}" if params[:pagina].present?
    self.query << "por_pagina=#{params[:por_pagina]}" if params[:por_pagina].present?

    url_especies = "#{CONFIG.enciclovida_api}/especies/filtros?#{query.join('&')}"

    begin
      rest = RestClient.get(url_especies)
      resultados = JSON.parse(rest)
    rescue => e
      return self.resp = { estatus: false, msg: e.message }
    end

    self.resp = { estatus: true, resultados: resultados, totales: resp[:totales] }
  end

  # Regresa el conteo de especies del servicio de /especies/filtros
  def respuesta_especies_filtros_conteo
    url_conteo = "#{CONFIG.enciclovida_api}/especies/filtros/conteo?#{query.join('&')}"

    begin
      rest = RestClient.get(url_conteo)
      resultados = JSON.parse(rest).first
    rescue => e
      return self.resp = { estatus: false, msg: e.message }
    end

    if resultados['nespecies'].to_i > 0
      self.resp = { estatus: true, totales: resultados['nespecies'].to_i }
    else
      self.resp = { estatus: false, msg: 'No existe ningun resultado con esos filtros. Intenta cambiando los filtros.' }
    end
  end

  # Asocia la información a desplegar en la vista, iterando los resultados
  def asocia_informacion_taxon
    resp[:resultados].each do |e|
      if scat = Scat.where(catalogo_id: e['idnombrecatvalido']).first
        next unless especie = scat.especie

        if a = especie.adicional
          especie.x_foto_principal = a.foto_principal if a.foto_principal.present?
          especie.x_nombre_comun_principal = a.nombre_comun_principal if a.nombre_comun_principal.present?
        end

        self.taxones << { especie_id: especie.id, nombre_cientifico: especie.nombre_cientifico,
                          nombre_comun: especie.x_nombre_comun_principal, nregistros: e['nregistros'],
                          foto_principal: especie.x_foto_principal, catalogo_id: e['idnombrecatvalido'] }

        if params[:region_id].present? && params[:tipo_region].present?
          self.taxones.last.merge!({ snib_registros: "#{CONFIG.enciclovida_api}/especie/ejemplares?idnombrecatvalido=#{e['idnombrecatvalido']}&region_id=#{params[:region_id]}&tipo_region=#{params[:tipo_region]}&mapa=true" })
        else
          next unless p = especie.proveedor
          geodatos = p.geodatos
          if geodatos[:cuales].present? && geodatos[:cuales].include?('snib')
            self.taxones.last.merge!({ snib_registros: geodatos[:snib_mapa_json] })
          end
        end

      end  # Si esta en Scat
    end  # End each resultados
  end

  # Regresa true or false
  def tiene_filtros?
    (params[:grupo].present? && params[:grupo].any?) || (params[:dist].present? && params[:dist].any?) || (params[:edo_cons].present? && params[:edo_cons].present?)
  end

  # Las especies por pagina cuando escogio una region
  def dame_especies_por_pagina
    self.por_pagina = ESPECIES_POR_PAGINA
    self.pagina = params[:pagina].present? ? params[:pagina].to_i : 1
    self.totales = resp[:totales]

    if resp[:estatus] && resp[:totales] > 0
      if especies = resp[:resultados][(por_pagina*pagina-por_pagina)..por_pagina*pagina-1]
        self.resp[:resultados] = especies
        asocia_informacion_taxon
      else
        resp[:msg] = 'No hay más especies'
      end

      resp[:taxones] = taxones
    end
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

end