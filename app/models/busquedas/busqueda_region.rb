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


  private

  # REVISADO: Regresa los resultados de la busqueda avanzada
  def especies_filtros
    return unless tiene_filtros?
    self.taxones = Especie.select(:id).select("#{Scat.attribute_alias(:catalogo_id)} AS catalogo_id").joins(:scat).distinct
    por_especie_id
    por_nombre
    #estatus
    #solo_publicos
    estado_conservacion
    tipo_distribucion
    uso
    ambiente

    #return unless por_id_o_nombre
    categoria_por_nivel
  end

  # REVISADO: Por si selecciono una especie de redis
  def por_especie_id
    # Tiene mas importancia si escogio por id
    return unless (params[:especie_id].present? && !(params[:nivel].present? && params[:cat].present?))
    self.taxones = taxones.where(id: params[:especie_id])
  end
  
  # Por si escribio un nombre pero no lo selecciono de la lista de redis
  def por_nombre
    return unless (params[:nombre].present? && (params[:especie_id].present? && !(params[:nivel].present? && params[:cat].present?)))
    self.taxones = taxones.caso_nombre_comun_y_cientifico(params[:nombre].strip).left_joins(:nombres_comunes)
  end

  # REVISADO: Saca los hijos de las categorias taxonomica que especifico , de acuerdo con el especie_id que escogio
  def categoria_por_nivel
    return unless (params[:especie_id] && params[:cat].present? && params[:nivel].present?)

    begin
      self.taxon = Especie.find(params[:especie_id])
    rescue
      return
    end
    
    # Aplica el query para los descendientes
    self.taxones = taxones.where("#{Especie.attribute_alias(:ancestry_ascendente_directo)} LIKE '%,#{taxon.id},%'")

    # Se limita la busqueda al rango de categorias taxonomicas de acuerdo al nivel
    self.taxones = taxones.nivel_categoria(params[:nivel], params[:cat]).joins(:categoria_taxonomica)
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
    params[:especie_id].present? || params[:nombre].present? || (params[:grupo].present? && params[:grupo].any?) || (params[:dist].present? && params[:dist].any?) || (params[:edo_cons].present? && params[:edo_cons].any?) || (params[:uso].present? && params[:uso].any?) || (params[:ambiente].present? && params[:ambiente].present?)
  end

  # Devuelve las especies de acuerdo al numero de pagina y por pagina definido
  def especies_por_pagina
    return unless resp[:estatus]
    self.por_pagina = params[:por_pagina] || ESPECIES_POR_PAGINA
    self.pagina = params[:pagina].present? ? params[:pagina].to_i : 1
    offset = (pagina-1)*por_pagina
    limit = (pagina*por_pagina)-1

    if tiene_filtros?
      ids = taxones.map(&:catalogo_id) & resp[:resultados].keys
      idcats = ids.map{ |id| [id, resp[:resultados][id]] }.sort_by(&:last).reverse
    else  # es la primera pagina
      idcats = resp[:resultados].to_a
    end
    
    self.totales = idcats.length
    
    if totales > 0
      self.resp[:resultados] = idcats[offset..limit].to_h
    else
      self.resp[:resultados] = {}
    end
  end

end