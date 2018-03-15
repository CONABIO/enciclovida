class BusquedasController < ApplicationController
  before_action only: :resultados, if: -> {params[:busqueda] == 'avanzada'} do
    @no_render_busqueda_basica = true
  end
  before_action only: :avanzada do
    @no_render_busqueda_basica = true
  end

  skip_before_action :set_locale, only: [:cat_tax_asociadas]
  layout false, :only => [:cat_tax_asociadas]

  def avanzada
    filtros_iniciales
  end

  def resultados
    # Por si no coincidio nada
    @taxones = Especie.none

    if params[:busqueda] == 'basica'
      resultados_basica
    elsif params[:busqueda] == 'avanzada'
      resultados_avanzada
    else  # Default, error
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

  # Acción que genera los checklists de acuerdo a un set de resultados
  def checklist(sin_filtros=false)
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
    especie = Especie.find(params[:id])
    @categorias = especie.cat_tax_asociadas
  end

  def tabs
  end


  private

  # Los filtros de la busqueda avanzada y de los resultados
  def filtros_iniciales
    @reinos = Especie.select_grupos_iconicos.where(nombre_cientifico: Busqueda::GRUPOS_REINOS)
    @animales = Especie.select_grupos_iconicos.where(nombre_cientifico: Busqueda::GRUPOS_ANIMALES)
    @plantas = Especie.select_grupos_iconicos.where(nombre_cientifico: Busqueda::GRUPOS_PLANTAS)

    @nom_cites_iucn_todos = Catalogo.nom_cites_iucn_todos

    @distribuciones = TipoDistribucion.distribuciones(I18n.locale.to_s == 'es-cientifico')

    @prioritarias = Catalogo.prioritarias
  end

  # Busqueda basica
  def resultados_basica
    arbol = params[:arbol].present? && params[:arbol].to_i == 1
    vista_general = I18n.locale.to_s == 'es' ? true : false

    pagina = params[:pagina].present? ? params[:pagina].to_i : 1
    por_pagina = params[:por_pagina].present? ? params[:por_pagina].to_i : Busqueda::POR_PAGINA_PREDETERMINADO
    params[:solo_categoria] = params[:solo_categoria].gsub('-', ' ') if params[:solo_categoria].present?  # Para la categoria grupo especies

    if params[:solo_categoria].present?
      if vista_general
        scope = Especie.where(estatus: 2)
      else
        scope = Especie
      end

      scope = scope.where('nombre_categoria_taxonomica = ? COLLATE Latin1_general_CI_AI', params[:solo_categoria])

      # Por si desea descargar el formato en excel o csv sin que haga todos los querys
      if Lista::FORMATOS_DESCARGA.include?(params[:format])
        # Por si en la busqueda original estaba vacia
        if params[:nombre].strip.blank?
          @totales = scope.count
        else
          @totales = Busqueda.count_basica(params[:nombre], {vista_general: vista_general, solo_categoria: params[:solo_categoria]})
        end

      else
        if params[:nombre].strip.blank?
          @taxones = scope.datos_basicos.offset((pagina-1)*por_pagina).limit(por_pagina).order(:nombre_cientifico)
        else
          @taxones = Busqueda.basica(params[:nombre], {vista_general: vista_general, pagina: pagina, por_pagina: por_pagina,
                                                       solo_categoria: params[:solo_categoria]})
        end

        @taxones.each do |t|
          t.cual_nombre_comun_coincidio(params[:nombre])
        end
      end

    else  # Es una busqueda para desplegar el TAB principal

      # Fue una busqueda vacia, te da todos los resultados
      if params[:nombre].strip.blank?
        if !Lista::FORMATOS_DESCARGA.include?(params[:format])
          @totales = if vista_general
                       scope = Especie.where(estatus: 2)
                       scope.count
                     else
                       scope = Especie
                       scope.count
                     end

          @taxones = scope.datos_basicos.offset((pagina-1)*por_pagina).limit(por_pagina).order(:nombre_cientifico)

          # Para separarlos por categoria
          @por_categoria = scope.select('nombre_categoria_taxonomica, count(*) AS cuantos').categoria_taxonomica_join.adicional_join.group('nombre_categoria_taxonomica').
              map{|t| {nombre_categoria_taxonomica: t.nombre_categoria_taxonomica, cuantos: t.cuantos, url: "#{request.original_url}&solo_categoria=#{I18n.transliterate(t.nombre_categoria_taxonomica).downcase.gsub(' ','_')}"}}

          @taxones.each do |t|
            t.cual_nombre_comun_coincidio(params[:nombre])
          end
        end

      else  # Es una busqueda NO vacia en el nombre
        @totales = Busqueda.count_basica(params[:nombre], {vista_general: vista_general, solo_categoria: params[:solo_categoria]})

        # Hubo resultados
        if @totales > 0

          # Por si desea descargar el formato en excel o csv sin que haga todos los querys
          if !Lista::FORMATOS_DESCARGA.include?(params[:format])
            @taxones = Busqueda.basica(params[:nombre], {vista_general: vista_general, pagina: pagina, por_pagina: por_pagina})
            @por_categoria = Busqueda.por_categoria_busqueda_basica(params[:nombre], {vista_general: vista_general, original_url: request.original_url})

            #puts @taxones.to_sql
            @taxones.each do |t|
              t.cual_nombre_comun_coincidio(params[:nombre])
            end
          end

        else # Si no hubo resultados, tratamos de encontrarlos con el fuzzy match
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

        end  # Fin de posibles resultados
      end  #Fin nombre.blank?
    end  # Fin solo_categoria

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
        format.xlsx { descargar_taxa_excel }
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
        format.xlsx { descargar_taxa_excel }
      end
    end  # end respond_to
  end

  def resultados_avanzada
    pagina = (params[:pagina] || 1).to_i

    busqueda = Busqueda.new
    busqueda.params = params
    busqueda.es_cientifico = I18n.locale.to_s == 'es-cientifico' ? true : false
    busqueda.original_url = request.original_url
    busqueda.formato = request.format.symbol.to_s
    busqueda.avanzada

    @totales = busqueda.totales
    @por_categoria = busqueda.por_categoria || []
    @taxones = busqueda.taxones

    response.headers['x-total-entries'] = @totales.to_s if @totales > 0

    respond_to do |format|
      if params[:solo_categoria].present? && @taxones.length > 0 && pagina == 1  # Imprime el inicio de un TAB
        format.html { render :partial => 'busquedas/resultados' }
        format.json { render json: {taxa: @taxones} }
        format.xlsx { descargar_taxa_excel }
      elsif pagina > 1 && @taxones.length > 0  # Imprime un set de resultados con el scrolling
        format.html { render :partial => 'busquedas/_resultados' }
        format.json { render json: {taxa: @taxones} }
      elsif (@taxones.length == 0 || @totales == 0) && pagina > 1  # Cuando no hay resultados en la busqueda o el scrolling
        format.html { render plain: '' }
        format.json { render json: {taxa: []} }
      elsif params[:checklist].present? && params[:checklist].to_i == 1  # Imprime el checklist de la taxa dada
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
        filtros_iniciales
        set_filtros

        format.html { render action: 'resultados' }
        format.json { render json: { taxa: @taxones, x_total_entries: @totales, por_categroria: @por_categoria.present? ? @por_categoria : [] } }
        format.xlsx { descargar_taxa_excel }
      end

    end  # end respond_to
  end

  def descargar_taxa_excel
    lista = Lista.new
    columnas = Lista::COLUMNAS_DEFAULT + Lista::COLUMNAS_RIESGO_COMERCIO + Lista::COLUMNAS_CATEGORIAS_PRINCIPALES
    lista.columnas = columnas.join(',')
    lista.formato = 'xlsx'
    lista.cadena_especies = request.original_url
    lista.usuario_id = 0  # Quiere decir que es una descarga, la guardo en lista para tener un control y poder correr delayed_job
    vista_general = I18n.locale.to_s == 'es' ? true : false
    basica = params[:busqueda] == 'basica' ? true : false

    # Si es una descarga de la busqueda basica y viene del fuzzy match
    if basica  && @taxones.present? && @taxones.any?
      @atributos = columnas
      @taxones = lista.datos_descarga(@taxones)
      # el nombre de la lista es cuando la bajo ya que no metio un correo
      lista.nombre_lista = Time.now.strftime("%Y-%m-%d_%H-%M-%S-%L") + '_taxa_EncicloVida'

      if Rails.env.production?  # Solo en produccion la guardo
        render(xlsx: 'resultados') if lista.save
      else
        render xlsx: 'resultados'
      end

    elsif @totales > 0
      # Para saber si el correo es correcto y poder enviar la descarga
      con_correo = Usuario::CORREO_REGEX.match(params[:correo]) ? true : false

      if @totales <= 200  # Si son menos de 200, es optimo para bajarlo en vivo
        # el nombre de la lista es cuando la bajo ya que no metio un correo
        lista.nombre_lista = Time.now.strftime("%Y-%m-%d_%H-%M-%S-%L") + '_taxa_EncicloVida'

        if basica
          taxones = Busqueda.basica(params[:nombre], {vista_general: vista_general, todos: true, solo_categoria: params[:solo_categoria]})
        end

        @taxones = lista.datos_descarga(@taxones)
        @atributos = columnas

        if Rails.env.production?  # Solo en produccion la guardo
          render(xlsx: 'resultados') if lista.save
        else
          render xlsx: 'resultados'
        end

      else  # Creamos el excel y lo mandamos por correo por medio de delay_job, mas de 200
        if con_correo
          # el nombre de la lista es cuando la solicito? y el correo
          lista.nombre_lista = Time.now.strftime("%Y-%m-%d_%H-%M-%S-%L") + "_taxa_EncicloVida|#{params[:correo]}"

          if Rails.env.production?
            if basica
              opts = params.merge({vista_general: vista_general, todos: true, solo_categoria: params[:solo_categoria]})
              lista.delay(queue: 'descargar_taxa').to_excel(opts.merge(basica: basica, correo: params[:correo])) if lista.save
            else
              lista.delay(queue: 'descargar_taxa').to_excel({busqueda: busqueda.distinct.to_sql, avanzada: true, correo: params[:correo]}) if lista.save
            end

          else  # Para develpment o test
            if basica  # si es busqueda basica
              opts = params.merge({vista_general: vista_general, todos: true, solo_categoria: params[:solo_categoria]})
              lista.to_excel(opts.merge(basica: basica, correo: params[:correo]))
            else
              lista.to_excel({busqueda: @taxones.to_sql, avanzada: true, correo: params[:correo]}) if lista.save
            end
          end

          render json: {estatus: 1}
        else  # Por si no puso un correo valido
          render json: {estatus: 0}
        end

      end

    else  # No entro a ningun condicional, es un error
      render json: {estatus: 0}
    end  # end totales > 0
  end  # end metodo

  # REVISADO: Parametros para poner en los filtros y saber cual escogio
  def set_filtros
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
  end
end
