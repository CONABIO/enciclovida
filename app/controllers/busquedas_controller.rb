class BusquedasController < ApplicationController

  skip_before_filter :set_locale, only: [:cat_tax_asociadas]
  layout false, :only => [:cat_tax_asociadas]

  def basica
  end

  def avanzada
  end

  def resultados
    @oldparams = []
    params.each do |k,v|
      @oldparams += case k
                      when 'id_nom_cientifico'
                        [k+'_'+v]
                      when 'edo_cons'
                        v.map{|x| 'edo_cons_'+x.parameterize}
                      when 'dist'
                        v.map{|x| 'dist_'+x.parameterize}
                      when 'prioritaria'
                        v.map{|x| 'prior_'+x.parameterize}
                      else
                        next
                    end
    end

    # Por si no coincidio nada
    @taxones = Especie.none
    # Despliega directo el taxon, si paso id
    if params[:id].present?
      redirect_to especie_path(params[:id])
    else

      # Hace el query del tipo de busqueda
      case params[:busqueda]

        when 'nombre_comun'
          estatus =  I18n.locale.to_s == 'es-cientifico' ?  (params[:estatus].join(',') if params[:estatus].present?) : '2'
          select = 'NombreComun.datos_basicos'
          select_count = 'NombreComun.datos_count'
          condiciones = ".caso_insensitivo('nombre_comun', \"#{params[:nombre_comun].limpia_sql}\").
                where('especies.id IS NOT NULL').where(\"estatus IN (#{estatus ||= '2, 1'})\").distinct.order('nombre_comun ASC')"
          condiciones_count = ".caso_insensitivo('nombre_comun', \"#{params[:nombre_comun].limpia_sql}\").
                where('especies.id IS NOT NULL').where(\"estatus IN (#{estatus ||= '2, 1'})\")"
          sql = select << condiciones
          sql_count = select_count << condiciones_count

          query = eval(sql).to_sql
          consulta = Bases.distinct_limpio query
          totales = eval(sql_count)[0].cuantos
          pagina = params[:pagina].present? ? params[:pagina].to_i : 1

          if totales > 0
            @taxones = consulta << " ORDER BY nombre_comun ASC OFFSET #{(pagina-1)*params[:por_pagina].to_i} ROWS FETCH NEXT #{params[:por_pagina].to_i} ROWS ONLY"
            @taxones = NombreComun.find_by_sql(@taxones)
            @paginacion = paginacion(totales, pagina, params[:por_pagina] ||= Busqueda::POR_PAGINA_PREDETERMINADO)

          else
            if @taxones.empty?
              ids=FUZZY_NOM_COM.find(params[:nombre_comun], limit=CONFIG.limit_fuzzy)

              if ids.present?
                @taxones = NombreComun.none
                taxones = NombreComun.datos_basicos.caso_rango_valores('nombres_comunes.id', "#{ids.join(',')}").
                    where("estatus IN (#{estatus ||= '2, 1'})").distinct.order('nombre_comun ASC').to_sql
                consulta = Bases.distinct_limpio(taxones) << ' ORDER BY nombre_comun ASC'
                res = NombreComun.find_by_sql(consulta)

                res.each do |taxon|
                  # Si la distancia entre palabras es menor a 3 que muestre la sugerencia
                  distancia = Levenshtein.distance(params[:nombre_comun].downcase, taxon.nombre_comun.downcase)
                  @coincidencias='¿Quizás quiso decir algunos de los siguientes taxones?'.html_safe

                  if distancia < 3
                    @taxones <<= taxon
                  else
                    next
                  end
                end
              end
            end

            # Para que saga el total tambien con el fuzzy match
            @paginacion = paginacion(@taxones.length, pagina, params[:por_pagina] ||= Busqueda::POR_PAGINA_PREDETERMINADO) if @taxones.any? ##CAMBIAR para resultados_controller
          end


          if !@taxones.empty? && params[:pagina].present? && params[:pagina].to_i > 1
            # Para desplegar solo una categoria de resultados, o el paginado con el scrolling
            render :partial => 'busquedas/_resultados'
          elsif @taxones.empty? && params[:pagina].present? && params[:pagina].to_i > 1
            # El scrolling acaba
            render text: ''
          elsif @taxones.empty?
            redirect_to  '/inicio/error', :notice => 'Tu búsqueda no dio ningun resultado.'
          end

        # Ojo si no entro a ningun condicional desplegara el render normal de resultados.

        when 'nombre_cientifico'
          arbol = params[:arbol].present? && params[:arbol].to_i == 1

          #Si pido arbol, entonces a estatus pegale nil para que abajito ponga ('1,2')
          estatus = arbol ? nil : (I18n.locale.to_s == 'es-cientifico' ?  (params[:estatus].join(',') if params[:estatus].present?) : '2')

          #if arbol
          sql = "Especie.datos_basicos.caso_insensitivo('nombre_cientifico', \"#{params[:nombre_cientifico].limpia_sql}\").where(\"estatus IN (#{estatus ||= '2, 1'})\").order('nombre_cientifico ASC')"

          consulta = eval(sql).to_sql
          totales = eval(sql).count
          pagina = params[:pagina].present? ? params[:pagina].to_i : 1

          if totales > 0
            @taxones = consulta << " OFFSET #{(pagina-1)*params[:por_pagina].to_i} ROWS FETCH NEXT #{params[:por_pagina].to_i} ROWS ONLY"
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


        when 'avanzada'
          #Es necesario hacer un index con estos campos para aumentar la velocidad
          condiciones = []
          joins = []
          busqueda = 'Especie.datos_basicos'

          conID = ''
          nombre_cientifico = ''
          distinct = false

          params.each do |key, value|  #itera sobre todos los campos

            if key == 'id_nom_cientifico' && value.present?
              conID = value.to_i
            elsif conID.blank? && key == 'id_nom_comun' && value.present?
              conID = value.to_i
            end

            if key == 'nombre_cientifico' && value.present? && conID.blank?
              nombre_cientifico << value.gsub("'", "''")
              condiciones << ".caso_insensitivo('nombre_cientifico', \"#{nombre_cientifico.limpia_sql}\")"
            end

            if key == 'nombre_comun' && value.present? && conID.blank?
              joins << '.nombres_comunes_join'
              condiciones << ".caso_insensitivo('nombres_comunes.nombre_comun', \"#{value.limpia_sql}\")"
            end
          end

          # Parte de la categoria taxonomica
          if params[:cat].present? && params[:nivel].present?
            if conID.present?                 #join a la(s) categorias taxonomicas (params)
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
          else       # busquedas directas
            condiciones << ".caso_sensitivo('especies.id', '#{conID}')" if conID.present?
          end

          #Parte del estatus
          condiciones << ".caso_rango_valores('estatus', '#{params[:estatus].join(',')}')" if params[:estatus].present?

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
          if params[:prioritaria].present?
            joins << '.catalogos_join'
            condiciones << ".caso_rango_valores('catalogos.descripcion', \"'#{params[:prioritaria].join("','")}'\")"
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
            format.html { redirect_to  '/inicio/error', :notice => 'Búsqueda incorrecta por favor intentalo de nuevo.' }
          end
      end  # Fin switch
    end
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
