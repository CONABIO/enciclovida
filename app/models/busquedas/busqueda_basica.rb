class BusquedaBasica < Busqueda

  # REVISADO: Regresa la busqueda basica
  def resultados_basica
    paginado_y_offset
    estatus
    solo_categoria

    return unless por_id_o_nombre

    conteo_por_categoria_taxonomica
    dame_totales

    if totales > 0
      resultados
      return
    end

##########################

    arbol = params[:arbol].present? && params[:arbol].to_i == 1
    vista_general = I18n.locale.to_s == 'es' ? true : false


# Si no hubo resultados, tratamos de encontrarlos con el fuzzy match
    ids_comun = FUZZY_NOM_COM.find(params[:nombre].strip, limit=CONFIG.limit_fuzzy)
    ids_cientifico = FUZZY_NOM_CIEN.find(params[:nombre].strip, limit=CONFIG.limit_fuzzy)

    if ids_comun.any? || ids_cientifico.any?
      sql = "Especie.datos_basicos(['nombre_comun', 'ancestry_ascendente_directo', 'cita_nomenclatural']).nombres_comunes_join"

      # Parte del estatus
      if vista_general
        sql << ".where('estatus=2')"
      end

      if ids_comun.any? && ids_cientifico.any?
        sql << ".where(\"nombres_comunes.id IN (#{ids_comun.join(',')}) OR especies.id IN (#{ids_cientifico.join(',')})\")"
      elsif ids_comun.any?
        sql << ".caso_rango_valores('nombres_comunes.id', \"#{ids_comun.join(',')}\")"
      elsif ids_cientifico.any?
        sql << ".caso_rango_valores('especies.id', \"#{ids_cientifico.join(',')}\")"
      end

      query = eval(sql).distinct.to_sql
      consulta = Bases.distinct_limpio(query) << " ORDER BY nombre_cientifico ASC OFFSET #{(pagina-1)*por_pagina} ROWS FETCH NEXT #{por_pagina} ROWS ONLY"
      taxones = Especie.find_by_sql(consulta)

      ids_totales = []

      taxones.each do |taxon|
        # Para evitar que se repitan los taxones con los joins
        next if ids_totales.include?(taxon.id)
        ids_totales << taxon.id

        # Si la distancia entre palabras es menor a 3 que muestre la sugerencia
        if taxon.nombre_comun.present?
          distancia = Levenshtein.distance(params[:nombre].downcase, taxon.nombre_comun.downcase)
          @taxones <<= taxon if distancia < 3
        end

        distancia = Levenshtein.distance(params[:nombre].downcase, taxon.nombre_cientifico.limpiar.downcase)
        @taxones <<= taxon if distancia < 3
      end
    end

# Para que saga el total tambien con el fuzzy match
    if @taxones.any?
      @taxones.each do |t|
        t.cual_nombre_comun_coincidio(params[:nombre], true)
      end

      @fuzzy_match = '¿Quizás quiso decir algunos de los siguientes taxones?'.html_safe
    end

    @totales = @taxones.length

  end

end