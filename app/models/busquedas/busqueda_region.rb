class BusquedaRegion < Busqueda

  attr_accessor :resp

  ESPECIES_POR_PAGINA = 8.freeze

  def initialize
    self.taxones = []
    self.totales = 0
  end

  # Regresa un listado de especies por pagina, de acuerdo a la region y los filtros seleccionados
  def especies
    especies_por_region
    return unless resp[:estatus]
    especies_filtros
    especies_por_pagina
    asocia_informacion_taxon

    self.resp[:taxones] = taxones
    self.resp[:totales] = totales
    self.resp[:resultados] = nil
  end

  # Consulta los querys guardados en cache o los consulta al vuelo
  def especies_por_region
    snib = Geoportal::Snib.new
    snib.params = params
    snib.especies
    self.resp = snib.resp
  end

  # Borra el cache de las especies por region
  def borra_cache_especies_por_region
    Rails.cache.delete("br_#{params[:tipo_region]}_#{params[:region_id]}") if Rails.cache.exist?("br_#{params[:tipo_region]}_#{params[:region_id]}")
  end


  private

  # REVISADO: Regresa los resultados de la busqueda avanzada
  def especies_filtros
    return unless tiene_filtros?
    self.taxones = Especie.select(:id).select("#{Scat.attribute_alias(:catalogo_id)} AS catalogo_id").joins(:scat).distinct

    estatus
    #solo_publicos
    estado_conservacion
    tipo_distribucion
    uso
    #ambiente
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

  # Devuelve las especies de acuerdo al numero de pagina y por pagina definido
  def especies_por_pagina
    return unless resp[:estatus]
    self.por_pagina = params[:por_pagina] || ESPECIES_POR_PAGINA
    self.pagina = params[:pagina].present? ? params[:pagina].to_i : 1
    offset = (pagina-1)*por_pagina
    limit = (pagina*por_pagina)-1

    if taxones.any?  # Quiere decir que tuvo algun filtro
      ids = taxones.map(&:catalogo_id) & resp[:resultados].keys
      idcats = ids.map{ |id| [id, resp[:resultados][id]] }.sort_by(&:last).reverse
    else  # Es la pagina inicial de busquedas por region
      idcats = resp[:resultados].to_a
    end
    
    self.totales = idcats.length
    self.resp[:resultados] = idcats[offset..limit].to_h
  end

end