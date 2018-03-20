class BusquedaBasica < Busqueda

  # REVISADO: Regresa la busqueda basica
  def resultados_basica
    paginado_y_offset
    estatus
    solo_categoria

    return unless por_id_o_nombre

    conteo_por_categoria_taxonomica
    dame_totales

    if dame_totales > 0
      resultados
    else
      resultados_fuzzy_match
    end
  end

  # Devuelve los resultados de una busqueda normal
  def resultados
    self.taxones = taxones.select_basico.order(:nombre_cientifico)
    return if formato == 'xlsx'

    self.taxones = taxones.offset(offset).limit(por_pagina)

    # Si solo escribio un nombre
    if params[:id].blank? && params[:nombre].present?
      taxones.each do |t|
        t.cual_nombre_comun_coincidio(params[:nombre])
      end
    end
  end

  # REVISADO: Si no hubo resultados, tratamos de encontrarlos con el fuzzy match
  def resultados_fuzzy_match
    ids_comun = FUZZY_NOM_COM.find(params[:nombre].strip, limit=CONFIG.limit_fuzzy).flatten.compact.uniq.sort.reverse
    ids_cientifico = FUZZY_NOM_CIEN.find(params[:nombre].strip, limit=CONFIG.limit_fuzzy).flatten.compact.uniq.sort.reverse
    ids_totales = []
    
    if ids_comun.empty? && ids_cientifico.empty?
      self.taxones = Especie.none
      self.totales = 0
      return
    end

    self.taxones = Especie.left_joins(:categoria_taxonomica, :adicional).select_basico(["#{NombreComun.table_name}.#{NombreComun.attribute_alias(:nombre_comun)}"]).order(:nombre_cientifico).offset(offset).limit(por_pagina).left_joins(:nombres_comunes).distinct

    if ids_comun.any?
      self.taxones =  taxones.where("#{NombreComun.table_name}.#{NombreComun.attribute_alias(:id)} IN (?)", ids_comun.join(','))
    end

    if ids_cientifico.any?
      self.taxones =  taxones.where(id: ids_cientifico)
    end

    taxones.each do |taxon|
      # Si la distancia entre palabras es menor a 3 que muestre la sugerencia
      if taxon.nombre_comun.present?
        distancia = Levenshtein.distance(params[:nombre].strip.downcase, taxon.nombre_comun.downcase)
        ids_totales << taxon if distancia < 3
      end

      distancia = Levenshtein.distance(params[:nombre].strip.downcase, taxon.nombre_cientifico.limpiar.downcase)
      ids_totales <<= taxon if distancia < 3
    end

    # Para mantener el valor en taxones
    self.taxones = ids_totales

    # Para que saga el total tambien con el fuzzy match
    taxones.each do |t|
      t.cual_nombre_comun_coincidio(params[:nombre], true)
    end

    #@fuzzy_match = '¿Quizás quiso decir algunos de los siguientes taxones?'.html_safe

    self.totales = taxones.length
  end

end