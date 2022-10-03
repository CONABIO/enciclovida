class BusquedaRegion < Busqueda

  attr_accessor :resp, :num_ejemplares

  ESPECIES_POR_PAGINA = 8.freeze
  ESPECIES_POR_PAGINA_API = [50, 100, 200]

  def initialize
    self.taxones = []
    self.totales = 0
    self.num_ejemplares = 0
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
    self.resp[:num_ejemplares] = num_ejemplares
    self.resp[:resultados] = nil

    # Para desplegar las flechas de siguiente o anterior
    if totales > 0
      if totales > ESPECIES_POR_PAGINA*params[:pagina].to_i
        self.resp['carga-siguientes-especies'] = true
      end  
      if params[:pagina].to_i > 1
        self.resp['carga-anteriores-especies'] = true
      end  
    end
  end

  # Consulta los querys guardados en cache o los consulta al vuelo
  def especies_por_region
    snib = Geoportal::Snib.new
    snib.params = params
    snib.especies
    self.resp = snib.resp
  end

  # Manda a llamar al modelo lista para la descarga
  def descarga_taxa_excel
    unless Usuario::CORREO_REGEX.match(params[:correo])
      self.resp = resp.merge({ estatus: false, msg: 'Favor de verificar el correo' })
      return
    end

    especies_por_region
    return unless resp[:estatus]
    especies_filtros
    especies_por_pagina(especies_excel: true)  # Para que regrese todas las especies que coincidieron
    
    unless resp[:estatus] && totales > 0
      self.resp = resp.merge({ estatus: false, msg: 'Error en la consulta. Favor de verificar tus filtros' })
      return
    end

    lista = Lista.new
    lista.columnas = params[:f_desc].join(',')
    lista.formato = 'xlsx'
    lista.cadena_especies = original_url
    lista.usuario_id = 0  # Quiere decir que es una descarga, la guardo en lista para tener un control y poder correr delayed_job
    # El nombre de la lista es cuando la solicito? y el correo
    lista.nombre_lista = Time.now.strftime("%Y-%m-%d_%H-%M-%S-%L") + "_taxa_EncicloVida|#{params[:correo]}"

    url_limpia = original_url.gsub('/especies.xlsx?','?')
    if Rails.env.production?
      lista.delay(queue: 'descargar_taxa').to_excel({ region: true, correo: params[:correo], original_url: url_limpia, hash_especies: resp[:resultados] }) if lista.save
    else  # Para develpment o test
      lista.to_excel({ region: true, correo: params[:correo], original_url: url_limpia, hash_especies: resp[:resultados] }) if lista.save
    end

    self.resp[:resultados] = nil
    self.resp.merge({ estatus: true, msg: nil })
  end

  # Para descargar la informacion de la guia
  def descarga_taxa_pdf
    unless Usuario::CORREO_REGEX.match(params[:correo])
      return self.resp = { estatus: false, msg: 'Favor de verificar el correo' }
    end    
        
    lista = Lista.new
    lista.formato = 'pdf'
    lista.cadena_especies = original_url
    lista.usuario_id = 0  # Quiere decir que es una descarga, la guardo en lista para tener un control y poder correr delayed_job
    lista.nombre_lista = Time.now.strftime("%Y-%m-%d_%H-%M-%S-%L") + "_guia_EncicloVida"

    if Rails.env.production?
      lista.delay(queue: 'descargar_taxa').to_pdf({ fecha: Time.now.strftime("%Y-%m-%d"), original_url: original_url }) if lista.save
    else  # Para que en development no la guarde en un trabajo
      lista.to_pdf({ fecha: Time.now.strftime("%Y-%m-%d"), original_url: original_url }) if lista.save
    end

    self.resp.merge({ estatus: true, msg: nil })      
  end

  def informacion_descarga_guia
    especies_por_region
    return unless resp[:estatus]
    especies_filtros
    especies_por_pagina(especies_guia: true)
    asocia_informacion_taxon(especies_guia: true)

    self.resp[:taxones] = taxones
    self.resp[:totales] = totales
    self.resp[:num_ejemplares] = num_ejemplares
    self.resp[:resultados] = nil
    
    # Para armar el titulo de la guia
    self.resp[:titulo_guia] = titulo_guia   
  end

  # Valida que los campos seleccionados sean validos para una posible descarga de guia
  def valida_descarga_guia
    if params[:especie_id].present?
      begin
        t = Especie.find(params[:especie_id])
        cat = t.categoria_taxonomica
        
        if [3,4,5,6].include?(cat.nivel1)
          self.resp = { estatus: true }
        else
          return self.resp = { estatus: false, msg: 'El taxón no es una clase, orden, familia o género' }
        end

      rescue => e
        return self.resp = { estatus: false, msg: 'El taxón seleccionado no existe' + e.inspect }
      end 
      
    else
      return self.resp = { estatus: false, msg: 'Se debe escoger un taxón' }  
    end

    if params[:region_id].present? && (params[:tipo_region].present? && %(municipio anp).include?(params[:tipo_region]))
      self.resp = { estatus: true }
    else
      self.resp = { estatus: false, msg: 'La región seleccionada no es un municipio o ANP' }
    end
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
    formas_crecimiento
    ambiente

    #return unless por_id_o_nombre
    #categoria_por_nivel
  end
  
  # Por si escribio un nombre pero no lo selecciono de la lista de redis
  def por_nombre
    return unless (params[:nombre].present? && params[:especie_id].blank?)
    self.taxones = taxones.caso_nombre_comun_y_cientifico(params[:nombre].strip).left_joins(:nombres_comunes)
  end

  # REVISADO: Saca los hijos de las categorias taxonomica que especifico , de acuerdo con el especie_id que escogio
  def por_especie_id
    return unless params[:especie_id].present?
    begin
      self.taxon = Especie.find(params[:especie_id])
    rescue
      return
    end
    
    if taxon.especie_o_inferior?  # Manda directo el taxon
      self.taxones = taxones.where(id: params[:especie_id])
    else  # Aplica el query para los descendientes
      self.taxones = taxones.where("#{Especie.attribute_alias(:ancestry_ascendente_directo)} LIKE '%,#{taxon.id},%'")

      # Se limita la busqueda al rango de categorias taxonomicas de acuerdo al nivel
      self.taxones = taxones.where("#{CategoriaTaxonomica.attribute_alias(:nombre_categoria_taxonomica)} IN (?)", ["especie"]).joins(:categoria_taxonomica)
    end
  end

  # Asocia la información a desplegar en la vista, iterando los resultados
  def asocia_informacion_taxon(opc={})
    self.taxones = []
    return unless (resp[:resultados].present? && resp[:resultados].any?)
    especies = Especie.select_basico(["#{Scat.attribute_alias(:catalogo_id)} AS catalogo_id"]).joins(:categoria_taxonomica, :adicional, :scat).where("#{Scat.attribute_alias(:catalogo_id)} IN (?)", resp[:resultados].keys)

    if opc[:especies_guia]
      especies = especies.includes(:catalogos, :tipos_distribuciones).order(ancestry_ascendente_directo: :desc)
    end

    especies.each do |especie|
      if opc[:especies_guia]
        cat_riesgo = asocia_cat_riesgo(especie)
        tipo_dist = asocia_tipo_dist(especie)
        self.taxones << { especie: especie, nregistros: resp[:resultados][especie.catalogo_id], cat_riesgo: cat_riesgo, tipo_dist: tipo_dist }
      else
        self.taxones << { especie: especie, nregistros: resp[:resultados][especie.catalogo_id] }
      end
    end

    if opc[:especies_guia].nil?
      self.taxones = taxones.sort_by{ |t| t[:nregistros] }.reverse
    end
  end

  # Regresa true or false
  def tiene_filtros?
    params[:especie_id].present? || params[:nombre].present? || (params[:grupo].present? && params[:grupo].any?) || (params[:dist].present? && params[:dist].any?) || (params[:edo_cons].present? && params[:edo_cons].any?) || (params[:uso].present? && params[:uso].any?) || (params[:ambiente].present? && params[:ambiente].present?) || (params[:forma].present? && params[:forma].present?)
  end

  # Devuelve las especies de acuerdo al numero de pagina y por pagina definido
  def especies_por_pagina(opc={})
    return unless resp[:estatus]
    self.por_pagina = (params[:por_pagina] || ESPECIES_POR_PAGINA).to_i
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
    self.num_ejemplares = idcats.sum {|r| r[1] }
    
    if totales > 0
      if opc[:especies_excel] || opc[:especies_guia]
        self.resp[:resultados] = idcats.to_h
      else
        self.resp[:resultados] = idcats[offset..limit].to_h
      end
    else
      self.resp[:resultados] = {}
    end
  end

  # Establece el titulo de acuerdo a la seleccion
  def titulo_guia
    titulo = []

    t = Especie.find(params[:especie_id])
    a = t.adicional

    tipo_region = params[:tipo_region] == "anp" ? "ANP " : "Municipio de "
    
    if a.nombre_comun_principal.present?
      titulo[0] = "Guía de #{a.nombre_comun_principal}"
    else
      titulo[0] = "Guía de #{t.nombre_cientifico}"
    end

    unless params[:nombre_region].present?
      region = "geoportal/#{params[:tipo_region]}".camelize.constantize.campos_min.find(params[:region_id])
      params[:nombre_region] = region.nombre_publico
    end

    titulo[1] = tipo_region + params[:nombre_region]
    titulo
  end

  # Asocia las categorias de riesgo y comercio int solo para la guia de especie
  def asocia_cat_riesgo(especie)
    cat_riesgo = []
    
    especie.catalogos.each do |cat|
      if [2,4].include?(cat.nivel1) && !(Catalogo::EVALUACION + Catalogo::AMBIENTE_EQUIV_MARINO + ["Riesgo bajo (LR): Dependiente de conservación (cd)"]).include?(cat.descripcion)
        cat_riesgo << cat.descripcion.estandariza
      end
    end

    cat_riesgo.uniq
  end

  # Asocia el tipo de distribucion solo para la guia de especie
  def asocia_tipo_dist(especie)
    tipo_dist = []
    
    especie.tipos_distribuciones.each do |dist|
      if TipoDistribucion::DISTRIBUCIONES_VISTA_GENERAL.include?(dist.descripcion)
        tipo_dist << dist.descripcion.estandariza
      end
    end

    tipo_dist.uniq!

    if tipo_dist.include?('endemica') && tipo_dist.include?('nativa')
      tipo_dist.delete('nativa')
    end

    tipo_dist
  end  

end