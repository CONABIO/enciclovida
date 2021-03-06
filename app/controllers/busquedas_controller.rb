class BusquedasController < ApplicationController

  before_action only: :resultados, if: -> {params[:busqueda] == 'avanzada'} do
    @no_render_busqueda_basica = true
  end

  before_action only: [:avanzada, :por_clasificacion, :por_clasificacion_hojas] do
    @no_render_busqueda_basica = true
  end

  before_action :set_especie, only: [:por_clasificacion, :por_clasificacion_hojas]
  skip_before_action :set_locale, only: [:cat_tax_asociadas]
  layout false, only: [:por_clasificacion_hojas]

  # REVISADO: Los filtros de la busqueda avanzada
  def avanzada
    cache_filtros_ev
  end

  # REVISADO: Los resultados de busqueda basica o avanzada
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

  # TODO: falta ver el funcionamiento del checklist; ¿talves contempalr la tabla plana?
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

  # REVISADO: Las categoras asociadas de acuerdo al taxon que escogio
  def cat_tax_asociadas
    especie = Especie.find(params[:id])
    @categorias = especie.cat_tax_asociadas
    render layout: false
  end

  def tabs
  end

  # Duvuelve la clasificacion taxonomica en forma de arbol
  def por_clasificacion
    if I18n.locale.to_s == 'es-cientifico'
      if @especie
        @taxones = Especie.arbol_inicial(@especie, 3)
      else
        @reinos = true
        @taxones = Especie.arbol_reinos(3)
      end

    else  # Vista general
      if @especie
        @taxones = Especie.arbol_inicial_obligatorias(@especie, 22)
        consulta_redis
      else
        @reinos = true
        @taxones = Especie.arbol_reinos(22)
      end
    end

    if params['fromShow']
      # Se debe especificar el nombre del archivo completo ya q al ser una llamada ajax, pide el JS por default
      render 'busquedas/clasificacion/por_clasificacion.erb', :layout => false, :locals => {conBuscador: false}
    else
      respond_to do |format|
        format.html { render 'busquedas/clasificacion/por_clasificacion', :locals => {conBuscador: true} }
        format.json { render 'busquedas/clasificacion/por_clasificacion.js.erb' }
      end
    end

  end

  # Devuelve las hojas de la categoria taxonomica con el nivel siguiente en cuestion
  def por_clasificacion_hojas
    if I18n.locale.to_s == 'es-cientifico'
      if @especie
        @taxones = Especie.arbol_hojas(@especie, 3, 'id_nombre_ascendente')
      end

    else  # Vista general
      if @especie
        @taxones = Especie.arbol_hojas_obligatorias(@especie, 22, 'id_ascend_obligatorio')
        consulta_redis
      end
    end

    render 'busquedas/clasificacion/por_clasificacion_hojas'
  end


  private

  # Consulta el redis para desplegar los datos
  def consulta_redis
    @taxones.each do |taxon|
      if taxon.nivel1 == 7 && taxon.nivel3 == 0
        begin
          redis_url = "#{CONFIG.site_url}/sm/search?term=#{taxon.nombre_cientifico}&types%5B%5D=especie&limit=5"
          resp = RestClient.get redis_url
          json_redis = JSON.parse(resp)

          json_redis["results"]["especie"].each do |especie|
            if especie["data"]["id"] == taxon.id
              taxon.jres = especie["data"]
            end
          end

        rescue => e
          next
        end
      end
    end
  end

  # TODO: falta ver el funcionamiento del checklist; ¿talves contempalr la tabla plana?
  def resultados_basica
    pagina = (params[:pagina] || 1).to_i

    busqueda = BusquedaBasica.new
    busqueda.params = params
    busqueda.es_cientifico = I18n.locale.to_s == 'es-cientifico' ? true : false
    busqueda.original_url = request.original_url
    busqueda.formato = request.format.symbol.to_s
    busqueda.resultados_basica

    @totales = busqueda.totales
    @por_categoria = busqueda.por_categoria || []
    @taxones = busqueda.taxones
    @fuzzy_match = busqueda.fuzzy_match
    arbol = false

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

      elsif params[:solo_categoria].present? && @taxones.length > 0 && pagina == 1  # Imprime el inicio de un TAB
        format.html { render :partial => 'busquedas/resultados' }
        format.json { render json: {taxa: @taxones} }
        format.xlsx { descargar_taxa_excel }
      elsif pagina > 1 && @taxones.length > 0  # Imprime un set de resultados con el scrolling
        # Despliega el paginado del TAB que tiene todos
        format.html { render :partial => 'busquedas/_resultados' }
        format.json { render json: {taxa: @taxones} }
      elsif (@taxones.length == 0 || @totales == 0) && pagina > 1  # Cuando no hay resultados en la busqueda o el scrolling
        format.html { render plain: '' }
        format.json { render json: {taxa: []} }
      else  # Ojo si no entro a ningun condicional desplegará el render normal (resultados.html.erb)
        format.html { render action: 'resultados' }
        format.json { render json: { taxa: @taxones, x_total_entries: @totales, por_categoria: @por_categoria.present? ? @por_categoria : [] } }
        format.xlsx { descargar_taxa_excel }
      end
    end  # end respond_to
  end

  # TODO: falta ver el funcionamiento del checklist; ¿talves contempalr la tabla plana?
  def resultados_avanzada
    pagina = (params[:pagina] || 1).to_i

    busqueda = BusquedaAvanzada.new
    busqueda.params = params
    busqueda.es_cientifico = I18n.locale.to_s == 'es-cientifico' ? true : false
    busqueda.original_url = request.original_url
    busqueda.formato = request.format.symbol.to_s
    busqueda.resultados_avanzada

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
        @bibliografias = []
        @categorias_checklist = busqueda.categorias_checklist

        format.html { render 'busquedas/checklist/checklists' }
        format.pdf do  #Para imprimir el listado en PDF
          #ruta = Rails.root.join('public', 'pdfs').to_s
          #fecha = Time.now.strftime("%Y%m%d%H%M%S")
          #pdf = "#{ruta}/#{fecha}_#{rand(1000)}.pdf"
          #FileUtils.mkpath(ruta, :mode => 0755) unless File.exists?(ruta)

          render pdf: 'listado_de_especies',
                 template: 'busquedas/checklist/checklists.pdf.erb',
                 encoding: 'UTF-8',
                 wkhtmltopdf: CONFIG.wkhtmltopdf_path,
                 page_size: 'Letter',
                 disposition: 'attachment',
                 #show_as_html: true,
                 header: {
                     html: {
                         template: 'busquedas/checklist/header.html.erb'
                     },
                     line: true,
                     spacing: 5,
                 },
                 footer: {
                     html: {
                         template: 'busquedas/checklist/footer.html.erb'
                     },
                     right: '[page] de [topage]',
                     line: true,
                     spacing: 3
                 },
                 margin: {
                     top: 23,
                     bottom: 20
                 }
        end
        format.xlsx do  # Falta implementar el excel de salida
          @columnas = @taxones.to_a.map(&:serializable_hash)[0].map{|k,v| k}
        end
      else  # Ojo si no entro a ningun condicional desplegará el render normal (resultados.html.erb)
        cache_filtros_ev
        #set_filtros

        format.html { render action: 'resultados' }
        format.json { render json: { taxa: @taxones, x_total_entries: @totales, por_categroria: @por_categoria.present? ? @por_categoria : [] } }
        format.xlsx { descargar_taxa_excel }
      end

    end  # end respond_to
  end

  # REVISADO: La descarga de taxa en busqueda basica o avanzada
  def descargar_taxa_excel
    lista = Lista.new
    columnas = params[:f_desc].join(',')
    lista.columnas = columnas
    lista.formato = 'xlsx'
    lista.cadena_especies = request.original_url
    lista.usuario_id = 0  # Quiere decir que es una descarga, la guardo en lista para tener un control y poder correr delayed_job
    @atributos = columnas

    if @totales > 0  # Creamos el excel y lo mandamos por correo por medio de delay_job, mas de 200
      # Para saber si el correo es correcto y poder enviar la descarga
      if Usuario::CORREO_REGEX.match(params[:correo]) ? true : false
        # el nombre de la lista es cuando la solicito? y el correo
        lista.nombre_lista = Time.now.strftime("%Y-%m-%d_%H-%M-%S-%L") + "_taxa_EncicloVida|#{params[:correo]}"

        if Rails.env.production?
          lista.delay(queue: 'descargar_taxa').to_excel({ busqueda: @taxones.to_sql, es_busqueda: true, correo: params[:correo], original_url: request.original_url.gsub('.xlsx?','?') }) if lista.save
        else  # Para develpment o test
          lista.to_excel({ busqueda: @taxones.to_sql, es_busqueda: true, correo: params[:correo], original_url: request.original_url.gsub('.xlsx?','?') }) if lista.save
        end

        render json: { estatus: 1 }
      else  # Por si no puso un correo valido
        render json: { estatus: 0 }
      end

    else  # No entro a ningun condicional, es un error
      render json: { estatus: 0 }
    end  # end totoales
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
      when 'edo_cons', 'dist', 'prior', 'estatus', 'uso', 'ambiente', 'reg'
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

  def set_especie
    if params[:especie_id].present?
      begin
        @especie = Especie.find(params[:especie_id])
      rescue
        render 'shared_b4/error' and return
      end
    end
  end

end
