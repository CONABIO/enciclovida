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
      arbol = params[:arbol].present? && params[:arbol].to_i == 1
      vista_general = I18n.locale.to_s == 'es' ? true : false

      pagina = params[:pagina].present? ? params[:pagina].to_i : 1
      por_pagina = params[:por_pagina].present? ? params[:por_pagina].to_i : Busqueda::POR_PAGINA_PREDETERMINADO

      if params[:solo_categoria].present?
        # Por si desea descargar el formato en excel o csv sin que haga todos los querys
        if Lista::FORMATOS_DESCARGA.include?(params[:format])
          @totales = 1
        else
          @taxones = Busqueda.basica(params[:nombre], {vista_general: vista_general, pagina: pagina, por_pagina: por_pagina,
                                                       solo_categoria: params[:solo_categoria]})
          @taxones.each do |t|
            t.cual_nombre_comun_coincidio(params[:nombre])
          end
        end

      else
        @totales = Busqueda.count_basica(params[:nombre], {vista_general: vista_general, solo_categoria: params[:solo_categoria]})

        if @totales > 0
          # Por si desea descargar el formato en excel o csv sin que haga todos los querys
          if !Lista::FORMATOS_DESCARGA.include?(params[:format])
            @taxones = Busqueda.basica(params[:nombre], {vista_general: vista_general, pagina: pagina, por_pagina: por_pagina})
            @por_categoria = Busqueda.por_categoria_busqueda_basica(params[:nombre], {vista_general: true, original_url: request.original_url})

            @taxones.each do |t|
              t.cual_nombre_comun_coincidio(params[:nombre])
            end
          end

        else
          ids_comun = FUZZY_NOM_COM.find(params[:nombre], limit=CONFIG.limit_fuzzy)
          ids_cientifico = FUZZY_NOM_CIEN.find(params[:nombre], limit=CONFIG.limit_fuzzy)

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

      response.headers['x-total-entries'] = @totales.to_s if @taxones.present?

      respond_to do |format|

        if @taxones.any? && arbol
          # Po si requieren que se genere el checklis
          @arboles = []

          @taxones.each do | taxon|
            # Primero hallo nombre comunes, mape unicamente el campo nombre_comun, le pego el nombre común principal (si tiene), saco los únicos y los ordeno alfabéticamente non-case
            nombres_comunes = (taxon.nombres_comunes.map(&:nombre_comun) << taxon.adicional.nombre_comun_principal).uniq.sort_by{|w| [I18n.transliterate(w.downcase), w] unless !(w.present?)}
            # Jalo unicamente los ancestros del taxón en cuestión
            arbolito = Especie.datos_arbol_para_json.where("especies.id = (#{taxon.id})")[0].arbol.split('/').join(',')

            # Género el árbol para cada uno de los ancestros recién obtenidos en la linea anterior de código ^
            @arboles << (Especie.datos_arbol_para_json_2.where("especies.id in (#{arbolito})" ).order('arbol') << {"distancia" => taxon.try("distancia") || 0} << {"nombres_comunes" => nombres_comunes.compact} )
          end

          format.json { render json: @arboles.to_json }

        elsif params[:solo_categoria].present? && @taxones.any? && pagina == 1
          # Despliega el inicio de un TAB que no sea el default
          format.html { render :partial => 'busquedas/resultados' }
          format.json { render json: {taxa: @taxones} }
        elsif pagina > 1 && @taxones.any?
          # Despliega el paginado del TAB que tiene todos
          format.html { render :partial => 'busquedas/_resultados' }
          format.json { render json: {taxa: @taxones} }
        elsif @taxones.empty? && pagina > 1
          # Quiere decir que el paginado acabo en algun TAB
          format.html { render text: '' }
          format.json { render json: {taxa: []} }
        else  # Ojo si no entro a ningun condicional desplegará el render normal (resultados.html.erb)
          format.html { render action: 'resultados' }
          format.json { render json: { taxa: @taxones, x_total_entries: @totales, por_categoria: @por_categoria.present? ? @por_categoria : [] } }
          format.xlsx {
            lista = Lista.new
            lista.columnas = Lista::COLUMNAS_DEFAULT + Lista::COLUMNAS_RIESGO_COMERCIO + Lista::COLUMNAS_CATEGORIAS_PRINCIPALES
            lista.formato = 'xlsx'

            # Viene del fuzzy match, por ende deben ser menos de 200 y se descargara directo
            if @taxones.present? && @taxones.any?
              @atributos = lista.columnas
              @taxones = lista.datos_descarga(@taxones)
              render xlsx: 'resultados'
            elsif @totales > 0
              if @totales <= 200
                # Si son menos de 200, es optimo para bajarlo en vivo
                taxones = Busqueda.basica(params[:nombre], {vista_general: vista_general, todos: true, solo_categoria: params[:solo_categoria]})
                @taxones = lista.datos_descarga(taxones)
                @atributos = lista.columnas
                render xlsx: 'resultados'
              else  # Creamos el excel y lo mandamos por correo por medio de delay_job
                opts = params.merge({vista_general: vista_general, todos: true, solo_categoria: params[:solo_categoria]})
                lista.to_excel(opts)
              end

            end
          }
        end
      end  # end respond_to

    elsif params[:busqueda] == 'avanzada'
      # Es necesario hacer un index con estos campos para aumentar la velocidad
      condiciones = []
      joins = []
      busqueda = 'Especie.datos_basicos'

      conID = params[:id]

      # Para hacer la condicion con el nombre_comun
      if conID.blank? && params[:nombre].present?
        condiciones << ".caso_nombre_comun_y_cientifico(\"#{params[:nombre].limpia_sql}\")"
        joins << '.nombres_comunes_join'
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
        # Si escogio uno lo pone, si escogio los dos es como no poner esta condicion
        if params[:estatus].present? && params[:estatus].length == 1
          condiciones << ".where('estatus=#{params[:estatus].first}')"
        end
      else  # En la busqueda general solo el valido
        condiciones << ".where('estatus=2')"
      end

      # Parte del tipo de ditribucion
      if params[:dist].present?
        #######################  Quitar cuando se arregle en la base
        if params[:dist].include?('Invasora') && params[:dist].length == 1  # Solo selecciono invasora
          condiciones << ".where('especies.invasora IS NOT NULL')"
        elsif params[:dist].include?('Invasora')  # No solo selecciono invasora, caso complejo
          params[:dist].delete('Invasora')  # Para quitar invasora y no lo ponga en el join
          joins << '.tipo_distribucion_join'
          condiciones << ".where(\"tipos_distribuciones.descripcion IN ('#{params[:dist].join("','")}') OR especies.invasora IS NOT NULL\")"
        else  # Selecciono cualquiera menos invasora
          joins << '.tipo_distribucion_join'
          condiciones << ".caso_rango_valores('tipos_distribuciones.descripcion', \"'#{params[:dist].join("','")}'\")"
        end
        #######################
      end

      # Parte del edo. de conservacion
      if params[:edo_cons].present?
        joins << '.catalogos_join'
        condiciones << ".caso_rango_valores('catalogos.descripcion', \"'#{params[:edo_cons].join("','")}'\")"
      end

      # Para las especies prioritarias
      if params[:prior].present?
        joins << '.catalogos_join'
        condiciones << ".caso_rango_valores('catalogos.descripcion', \"'#{params[:prior].join("','")}'\")"
      end

      # Parte de consultar solo un TAB (categoria taxonomica), se tuvo que hacer con nombre_categoria taxonomica,
      # ya que los catalogos no tienen estandarizados los niveles en la tabla categorias_taxonomicas  >.>
      if params[:solo_categoria]
        condiciones << ".where(\"nombre_categoria_taxonomica='#{params[:solo_categoria]}' COLLATE Latin1_general_CI_AI\")"
      end

      # Quita las condiciones y los joins repetidos
      condiciones_unicas = condiciones.uniq.join('')
      joins_unicos = joins.uniq.join('')
      busqueda << joins_unicos << condiciones_unicas      #pone el query basico armado

      # Para sacar los resultados por categoria
      @por_categoria = Busqueda.por_categoria(busqueda, request.original_url) if params[:solo_categoria].blank?

      pagina = params[:pagina].present? ? params[:pagina].to_i : 1
      por_pagina = params[:por_pagina].present? ? params[:por_pagina].to_i : Busqueda::POR_PAGINA_PREDETERMINADO

      @totales = eval(busqueda.gsub('datos_basicos','datos_count'))[0].totales

      if @totales > 0

        if params[:checklist] == '1' # Reviso si me pidieron una url que contien parametro checklist (Busqueda CON FILTROS)
          @taxones = Busqueda.por_arbol(busqueda)

          checklist
        else
          query = eval(busqueda).distinct.to_sql
          consulta = Bases.distinct_limpio(query) << " ORDER BY nombre_cientifico ASC OFFSET #{(pagina-1)*por_pagina} ROWS FETCH NEXT #{por_pagina} ROWS ONLY"
          @taxones = Especie.find_by_sql(consulta)

          # Si solo escribio un nombre
          if conID.blank? && params[:nombre].present?
            @taxones.each do |t|
              t.cual_nombre_comun_coincidio(params[:nombre])
            end
          end
        end
      end

      response.headers['x-total-entries'] = @totales.to_s if @taxones.present?

      respond_to do |format|
        # Para desplegar solo una categoria de resultados, o el paginado con el scrolling
        if params[:solo_categoria].present? && @taxones.any? && pagina == 1
          # Imprime el inicio de un TAB
          format.html { render :partial => 'busquedas/resultados' }
          format.json { render json: {taxa: @taxones} }
        elsif pagina > 1 && @taxones.any?
          format.html { render :partial => 'busquedas/_resultados' }
          format.json { render json: {taxa: @taxones} }
        elsif @taxones.empty? && pagina > 1
          format.html { render text: '' }
          format.json { render json: {taxa: []} }
        elsif params[:checklist].present? && params[:checklist].to_i == 1
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
        else  # Ojo si no entro a ningun condicional desplegará el render normal (resultados.html.erb)
          # Parametros para poner en los filtros y saber cual escogio
          @setParams = {}

          params.each do |k,v|
            # Evitamos valores vacios
            next unless v.present?

            case k
              when 'id', 'nombre', 'por_pagina'
                @setParams[k] = v
              when 'edo_cons', 'dist', 'prior', 'estatus'
                if @setParams[k].present?
                  @setParams[k] << v.map{ |x| x.parameterize if x.present?}
                else
                  @setParams[k] = v.map{ |x| x.parameterize if x.present?}
                end
              else
                next
            end
          end

          format.html { render action: 'resultados' }
          format.json { render json: { taxa: @taxones, x_total_entries: @totales, por_categroria: @por_categoria.present? ? @por_categoria : [] } }
          format.xlsx {
            lista = Lista.new
            lista.columnas = Lista::COLUMNAS_DEFAULT + Lista::COLUMNAS_RIESGO_COMERCIO + Lista::COLUMNAS_CATEGORIAS_PRINCIPALES
            lista.formato = 'xlsx'

            # Viene del fuzzy match, por ende deben ser menos de 200 y se descargara directo
            if @totales > 0
              # Para saber si el correo es correcto y poder enviar la descarga
              con_correo = Comentario::EMAIL_REGEX.match(params[:correo]) ? true : false

              if @totales <= 200
                # Si son menos de 200, es optimo para bajarlo en vivo
                query = eval(busqueda).distinct.to_sql
                consulta = Bases.distinct_limpio(query) << ' ORDER BY nombre_cientifico ASC'
                taxones = Especie.find_by_sql(consulta)

                @taxones = lista.datos_descarga(taxones)
                @atributos = lista.columnas

                render xlsx: 'resultados'

              else  # Creamos el excel y lo mandamos por correo por medio de delay_job
                if con_correo
                  if Rails.env.development?
                    lista.delay(:priority => 2).to_excel({busqueda: busqueda, avanzada: true, correo: params[:correo]})
                  else
                    lista.to_excel({busqueda: busqueda, avanzada: true, correo: params[:correo]})
                  end

                  render json: {estatus: 1}
                else
                  render json: {estatus: 0}
                end

              end

            end  # end totales
          }
        end

      end  # end respond_to

    else  # Default switch
      respond_to do |format|
        format.html { redirect_to  '/inicio/error', :notice => 'Búsqueda incorrecta por favor inténtalo de nuevo.' }
        format.json { render json: {taxa: []} }
      end
    end  # Fin if busqueda
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
