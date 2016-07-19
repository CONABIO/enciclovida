class BusquedasController < ApplicationController

  skip_before_filter :set_locale, only: [:cat_tax_asociadas]
  layout false, :only => [:cat_tax_asociadas]

  def basica
  end

  def avanzada
  end

  def resultados
    # Por si no coincidio nada
    @taxones = Especie.none

    if params[:busqueda] == 'basica'
      # Siempre estatus valido en la vista general
      estatus =  I18n.locale.to_s == 'es-cientifico' ? '2,1' : '2'

      # Buscamos coincidencias para el nombre comun
      select = "NombreComun.datos_basicos([],'FULL')"
      select_count = "NombreComun.datos_count('FULL')"
      condiciones = ".caso_nombre_comun_y_cientifico(\"#{params[:nombre].limpia_sql}\").
                where('especies.id IS NOT NULL').where(\"estatus IN (#{estatus})\")"

      # Parte de consultar solo un TAB (categoria taxonomica)
      if params[:solo_categoria].present?
        condiciones << ".caso_sensitivo('CONCAT(categorias_taxonomicas.nivel1,categorias_taxonomicas.nivel2,categorias_taxonomicas.nivel3,categorias_taxonomicas.nivel4)', '#{params[:solo_categoria]}')"
        select_count << '.categoria_taxonomica_join'
      end

      sql = select + condiciones
      sql_count = select_count << condiciones

      query = eval(sql).to_sql
      totales = eval(sql_count)[0].cuantos

      pagina = params[:pagina].present? ? params[:pagina].to_i : 1
      por_pagina = params[:por_pagina].present? ? params[:por_pagina].to_i : Busqueda::POR_PAGINA_PREDETERMINADO

      if totales > 0
        @taxones = query + " ORDER BY nombre_cientifico ASC OFFSET #{(pagina-1)*por_pagina} ROWS FETCH NEXT #{por_pagina} ROWS ONLY"
        @taxones = NombreComun.find_by_sql(@taxones)

        # La consulta que separa los resultados por categoria taxonomica
        sql_por_categotia_basica = Busqueda.por_categoria_basica(sql)
        @por_categoria = NombreComun.find_by_sql(sql_por_categotia_basica)

      else
        ids_comun = FUZZY_NOM_COM.find(params[:nombre], limit=CONFIG.limit_fuzzy)
        ids_cientifico = FUZZY_NOM_CIEN.find(params[:nombre], limit=CONFIG.limit_fuzzy)

        if ids_comun.any? || ids_cientifico.any?
          @taxones = NombreComun.none
          sql = "NombreComun.datos_basicos(['nombre_comun'],'FULL').where(\"estatus IN (#{estatus})\")"

          if ids_comun.any? && ids_cientifico.any?
            sql << ".where(\"nombres_comunes.id IN (#{ids_comun.join(',')}) OR especies.id IN (#{ids_cientifico.join(',')})\")"
          elsif ids_comun.any?
            sql << ".caso_rango_valores('nombres_comunes.id', \"#{ids_comun.join(',')}\")"
          elsif ids_cientifico.any?
            sql << ".caso_rango_valores('especies.id', \"#{ids_cientifico.join(',')}\")"
          end

          query = eval(sql).to_sql + " ORDER BY nombre_cientifico ASC OFFSET #{(pagina-1)*por_pagina} ROWS FETCH NEXT #{por_pagina} ROWS ONLY"
          res = NombreComun.find_by_sql(query)

          ids_totales = []
          res.each do |taxon|
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
          @coincidencias = '¿Quizás quiso decir algunos de los siguientes taxones?'.html_safe
        end

      end

      @paginacion = paginacion(@taxones.length, pagina, por_pagina)

      # Para desplegar solo una categoria de resultados, o el paginado con el scrolling
      if params[:solo_categoria].present?
        if params[:pagina].present? && params[:pagina].to_i > 1 && !@taxones.empty?
          render :partial => 'busquedas/_resultados'
        elsif @taxones.empty? && params[:pagina].to_i > 1 && !@taxones.empty?
          # Quiere decir que el paginado acabo en algun TAB que no es el default
          render text: ''
        else
          # Despliega el inicio de un TAB que no sea el default
          render :partial => 'busquedas/resultados'
        end
      elsif params[:pagina].present? && params[:pagina].to_i > 1 && @taxones.any?
        # Despliega el paginado del TAB que tiene todos
        render :partial => 'busquedas/_resultados'
      elsif @taxones.empty? && params[:pagina].present? && params[:pagina].to_i > 1
        # Quiere decir que el paginado acabo en algun TAB
        render text: ''
      elsif @taxones.empty?
        # La busqueda no dio ningun resultado
        redirect_to  '/inicio/error', :notice => 'Tu búsqueda no dio ningún resultado.'
      end
      # Ojo si no entro a ningun condicional desplegará el render normal (resultados.html.erb).

=begin
      when 'nombre_cientifico'
        arbol = params[:arbol].present? && params[:arbol].to_i == 1

        #Si pido arbol, entonces a estatus pegale nil para que abajito ponga ('1,2')
        estatus = arbol ? nil : (I18n.locale.to_s == 'es-cientifico' ?  (params[:estatus].join(',') if params[:estatus].present?) : '2')

        #if arbol
        sql = "Especie.datos_basicos.where(\"estatus IN (#{estatus ||= '2, 1'})\").distinct.order('nombre_cientifico ASC')"
        sql << ".caso_insensitivo('nombre_cientifico', '#{params[:nombre_cientifico].limpia_sql}')" if params[:nombre_cientifico].present?
        consulta = eval(sql).to_sql

        consulta = Bases.distinct_limpio consulta

        totales = eval(sql).count
        pagina = params[:pagina].present? ? params[:pagina].to_i : 1

        if totales > 0
          @taxones = consulta << " ORDER BY nombre_cientifico ASC OFFSET #{(pagina-1)*params[:por_pagina].to_i} ROWS FETCH NEXT #{params[:por_pagina].to_i} ROWS ONLY"
          @taxones = Especie.find_by_sql(@taxones)
          @paginacion = paginacion(totales, pagina, params[:por_pagina] ||= Busqueda::POR_PAGINA_PREDETERMINADO)
        else

          if @taxones.empty?
            ids=FUZZY_NOM_CIEN.find(params[:nombre_cientifico], limit=CONFIG.limit_fuzzy)

            if ids.present?
              @taxones = Especie.none
              taxones = Especie.datos_basicos.caso_rango_valores('especies.id', "#{ids.join(',')}").where("estatus IN (#{estatus ||= '2, 1'})").order('nombre_cientifico ASC')

              taxones.each do |taxon|
                # Si la distancia entre palabras es menor a 3 que muestre la sugerencia
                distancia = Levenshtein.distance(params[:nombre_cientifico].downcase, taxon.nombre_cientifico.limpiar.downcase)
                @coincidencias='¿Quizás quiso decir algunos de los siguientes taxones?'.html_safe

                if distancia < 3
                  taxon[:distancia]= distancia
                  @taxones <<= taxon

                else
                  next
                end
              end
            end
          end

          # Para que saga el total tambien con el fuzzy match
          @paginacion = paginacion(@taxones.length, pagina, params[:por_pagina] ||= Busqueda::POR_PAGINA_PREDETERMINADO) if @taxones.any?
        end

        if !@taxones.empty? && arbol
          @arboles = []
          @taxones.each do | taxon|
            #Primero hallo nombre comunes, mape unicamente el campo nombre_comun, le pego el nombre común principal (si tiene), saco los únicos y los ordeno alfabéticamente non-case
            nombres_comunes = (taxon.nombres_comunes.map(&:nombre_comun) << taxon.adicional.nombre_comun_principal).uniq.sort_by{|w| [I18n.transliterate(w.downcase), w] unless !(w.present?)}
            #Jalo unicamente los ancestros del taxón en cuestión
            arbolito = Especie.datos_arbol_para_json.where("especies.id = (#{taxon.id})")[0].arbol.split('/').join(',')

            #Género el árbol para cada uno de los ancestros recién obtenidos en la linea anterior de código ^
            @arboles << (Especie.datos_arbol_para_json_2.where("especies.id in (#{arbolito})" ).order('arbol') << {"distancia" => taxon.try("distancia") || 0} << {"nombres_comunes" => nombres_comunes.compact} )
          end
          render 'busquedas/arbol.json.erb'
        end

        if !@taxones.empty? && params[:pagina].present? && params[:pagina].to_i > 1
          # Para desplegar solo una categoria de resultados, o el paginado con el scrolling
          render :partial => 'busquedas/_resultados'
        elsif @taxones.empty? && params[:pagina].present? && params[:pagina].to_i > 1
          # El scrolling acaba
          render text: ''
        elsif @taxones.empty? && arbol #La búsqueda no obtuvo resultados y se regresa un array parseable vacío
          render :text => '[]'
        elsif @taxones.empty?
          redirect_to  '/inicio/error', :notice => 'Tu búsqueda no dio ningun resultado.'
        end

      # Ojo si no entro a ningun condicional desplegara el render normal de resultados.
=end

    elsif params[:busqueda] == 'avanzada'

      # Parametros para poner en los filtros y saber cual escogio
      @setParams = {}

      params.each do |k,v|
        # Evitamos valores vacios
        next unless v.present?

        case k
                        when 'id', 'nombre'
                          @setParams[k] = v
                          #[k+'_'+v]
                        when 'edo_cons', 'dist', 'prior'
                          #v.map{|x| k+'_'+x.parameterize}
                          if @setParams[k].present?
                            @setParams[k] << v.map{ |x| x.parameterize if x.present?}
                          else
                            @setParams[k] = v.map{ |x| x.parameterize if x.present?}
                          end
                        else
                          next
                     end
      end

      # Es necesario hacer un index con estos campos para aumentar la velocidad
      condiciones = []
      joins = []
      busqueda = 'Especie.datos_basicos'

      conID = params[:id]
      distinct = false

      # Para hacer la condicion con el nombre_comun
      if conID.blank? && params[:nombre].present?
        condiciones << ".caso_nombre_comun_y_cientifico(\"#{params[:nombre].limpia_sql}\")"
      end

      # Parte de la categoria taxonomica
      if conID.present? && params[:cat].present? && params[:nivel].present?
        taxon = Especie.find(conID)

        if taxon.is_root?
          condiciones << ".where(\"ancestry_ascendente_directo LIKE '#{taxon.id}%' OR especies.id=#{taxon.id}\")"
        else
          ancestros = taxon.ancestry_ascendente_directo
          condiciones << ".where(\"ancestry_ascendente_directo LIKE '#{ancestros}/#{taxon.id}%' OR especies.id IN (#{taxon.path_ids.join(',')})\")"
        end

        # Se limita la busqueda al rango de categorias taxonomicas de acuerdo al taxon que escogio
        condiciones << ".where(\"CONCAT(categorias_taxonomicas.nivel1,categorias_taxonomicas.nivel2,categorias_taxonomicas.nivel3,categorias_taxonomicas.nivel4) #{params[:nivel]} '#{params[:cat]}'\")"
      end

      # Parte del estatus
      if I18n.locale.to_s == 'es-cientifico'
        if params[:estatus].present?
          condiciones << ".caso_rango_valores('estatus', #{params[:estatus].join(',')})"
        end
      else  # En la busqueda general solo el valido
        condiciones << ".where('estatus=2')"
      end

      #Parte del tipo de ditribucion
      if params[:dist].present?
        #######################  Quitar cuando se arregle en la base
        if params[:dist].include?('Invasora') && params[:dist].length == 1  # Solo selecciono invasora
          condiciones << ".where('especies.invasora IS NOT NULL')"
        elsif params[:dist].include?('Invasora')  # No solo selecciono invasora, caso complejo
          params[:dist].delete('Invasora')  # Para quitar invasora y no lo ponga en el join
          joins << '.tipo_distribucion_join'
          condiciones << ".where(\"tipos_distribuciones.descripcion IN ('#{params[:dist].join("','")}') OR especies.invasora IS NOT NULL\")"
          distinct = true
        else  # Selecciono cualquiera menos invasora
          joins << '.tipo_distribucion_join'
          condiciones << ".caso_rango_valores('tipos_distribuciones.descripcion', \"'#{params[:dist].join("','")}'\")"
          distinct = true
        end
        #######################
      end

      #Parte del edo. de conservacion
      if params[:edo_cons].present?
        joins << '.catalogos_join'
        condiciones << ".caso_rango_valores('catalogos.descripcion', \"'#{params[:edo_cons].join("','")}'\")"
        distinct = true
      end

      # Para las especies prioritarias
      if params[:prior].present?
        joins << '.catalogos_join'
        condiciones << ".caso_rango_valores('catalogos.descripcion', \"'#{params[:prior].join("','")}'\")"
        distinct = true
      end

      # Parte de consultar solo un TAB (categoria taxonomica)
      if params[:solo_categoria] && conID.present?
        condiciones << ".caso_sensitivo('CONCAT(categorias_taxonomicas.nivel1,categorias_taxonomicas.nivel2,categorias_taxonomicas.nivel3,categorias_taxonomicas.nivel4)', '#{params[:solo_categoria]}')"
      end

      # Quita las condiciones y los joins repetidos
      condiciones_unicas = condiciones.uniq.join('')
      joins_unicos = joins.uniq.join('')
      busqueda << joins_unicos << condiciones_unicas      #pone el query basico armado

      # Para sacar los resultados por categoria
      @por_categoria = Busqueda.por_categoria(busqueda, distinct) if params[:solo_categoria].blank? && conID.present?
      pagina = params[:pagina].present? ? params[:pagina].to_i : 1

      if distinct
        totales = eval(busqueda.gsub('datos_basicos','datos_count'))[0].totales

        if totales > 0
          @paginacion = paginacion(totales, pagina, params[:por_pagina] ||= Busqueda::POR_PAGINA_PREDETERMINADO)

          if params[:checklist]=="1" # Reviso si me pidieron una url que contien parametro checklist (Busqueda CON FILTROS)
            @taxones = Busqueda.por_arbol(busqueda)
            checklist
          else
            query = eval(busqueda).distinct.to_sql
            consulta = Bases.distinct_limpio(query) << " ORDER BY nombre_cientifico ASC OFFSET #{(pagina-1)*params[:por_pagina].to_i} ROWS FETCH NEXT #{params[:por_pagina].to_i} ROWS ONLY"
            @taxones = Especie.find_by_sql(consulta)
          end
        end
      else
        totales = eval(busqueda).count

        if totales > 0
          @taxones = eval(busqueda).order('nombre_cientifico ASC').to_sql << " OFFSET #{(pagina-1)*params[:por_pagina].to_i} ROWS FETCH NEXT #{params[:por_pagina].to_i} ROWS ONLY"
          @paginacion = paginacion(totales, pagina, params[:por_pagina] ||= Busqueda::POR_PAGINA_PREDETERMINADO)

          if params[:checklist]=="1" # Reviso si me pidieron una url que contien parametro checklist (Busqueda SIN FILTROS)
            @taxones = Busqueda.por_arbol(busqueda, true)
            checklist(true)
          end
          @taxones = Especie.find_by_sql(@taxones)

        end
      end

      # Para desplegar solo una categoria de resultados, o el paginado con el scrolling
      if params[:solo_categoria].present?
        if params[:pagina].present? && params[:pagina].to_i > 1 && !@taxones.empty?
          render :partial => 'busquedas/_resultados'
        elsif @taxones.empty?
          render text: ''
        else
          render :partial => 'busquedas/resultados'
        end
      elsif params[:pagina].present? && params[:pagina].to_i > 1 && !@taxones.empty?
        render :partial => 'busquedas/_resultados'
      elsif @taxones.empty? && params[:pagina].present? && params[:pagina].to_i > 1
        render text: ''
      elsif params[:checklist].present? && params[:checklist].to_i == 1
        respond_to do |format|
          format.html { render 'busquedas/checklists' }
          format.pdf do  #Para imprimir el listado en PDF
            ruta = Rails.root.join('public', 'pdfs').to_s
            fecha = Time.now.strftime("%Y%m%d%H%M%S")
            pdf = "#{ruta}/#{fecha}_#{rand(1000)}.pdf"
            FileUtils.mkpath(ruta, :mode => 0755) unless File.exists?(ruta)

            render :pdf => 'listado_de_especies',
                   :save_to_file => pdf,
                   #:save_only => true,
                   :template => 'busquedas/checklists.pdf.erb',
                   :encoding => 'UTF-8',
                   :wkhtmltopdf => CONFIG.wkhtmltopdf_path,
                   :orientation => 'Landscape'
          end
          format.xlsx do  # Falta implementar el excel de salida
            @columnas = @taxones.to_a.map(&:serializable_hash)[0].map{|k,v| k}
          end
        end
      end

    else  # Default switch
      respond_to do |format|
        format.html { redirect_to  '/inicio/error', :notice => 'Búsqueda incorrecta por favor inténtalo de nuevo.' }
      end
    end  # Fin switch
  end

  # Servicio que por medio del nombre comun extrae todos los nombres comunes asociados al taxon (servicio para alejandro molina)
  def nombres_comunes
    select = "NombreComun.datos_basicos(['nombres_comunes.id'])"
    select_count = 'NombreComun.datos_count'

    if params[:exact].present? && params[:exact].to_i == 1
      condiciones = ".caso_sensitivo('nombre_comun', \"#{params[:q].limpia_sql}\").
                where('especies.id IS NOT NULL')"
    else
      condiciones = ".caso_insensitivo('nombre_comun', \"#{params[:q].limpia_sql}\").
                where('especies.id IS NOT NULL')"
    end

    sql = select << condiciones + ".distinct.order('nombre_comun ASC')"
    sql_count = select_count << condiciones

    query = eval(sql).to_sql
    consulta = Bases.distinct_limpio query
    totales = eval(sql_count)[0].cuantos

    @data = {}
    @data[:termino] = params[:q]
    @data[:numero_resultados] = totales
    @data[:resultados] = []

    if totales > 0
      consulta << ' ORDER BY nombre_comun ASC'
      nombres_comunes = NombreComun.find_by_sql(consulta)

      # Para no repetir los taxones
      especie_ids = []

      nombres_comunes.each do |nombre_comun|
        nombre_comun.especies.each do |especie|

          next if especie_ids.include?(especie.id)
          especie_ids << especie.id
          nombres = especie.nombres_comunes.map(&:nombre_comun)
          @data[:resultados] << {nombre_comun_coincidio: nombre_comun.nombre_comun, taxon: especie.nombre_cientifico, nombres_comunes: nombres}
        end
      end

    end

    render json: @data.to_json
  end

  def checklist(sin_filtros=false) #Acción que genera los checklists de aceurdo a un set de resultados
    if sin_filtros
      #Sin no tengo filtros, dibujo el checklist tal y caul como lo recibo (render )
    else
      padres = {}
      @taxones.each do |taxon|
        taxon.arbol.split('/').each do |p|
          padres[p.to_i]=''
        end
      end
      #Aquí entro al query sin filtros (a pesar de que mi búsqueda fue CON filtros) pq ya tengo todos los papás, ahora necesito sus datos y ordenarlos por campo arbol
      @taxones = Especie.datos_arbol_sin_filtros.where("especies.id in (#{padres.keys.join(',')})").order('arbol')
    end
  end

  def dame_listas
    respond_to do |format|
      format.html { render :json => dameListas(@listas) }
    end
  end

  # Las categoras asociadas de acuerdo al taxon que escogio
  def cat_tax_asociadas
    @especie = Especie.find(params[:id])
  end

  def tabs
  end

  def tipoDeBusqueda(tipo, columna, valor)
    case tipo.to_i
      when 1
        "caso_insensitivo('#{columna}', '#{valor}')"
      when 2
        "caso_empieza_con('#{columna}', '#{valor}')"
      when 3
        "caso_sensitivo('#{columna}', '#{valor}')"
      when 4
        "caso_termina_con('#{columna}', '#{valor}')"
      when 5
        "caso_rango_valores('#{columna}', \"#{valor}\")"
    end
  end
end
