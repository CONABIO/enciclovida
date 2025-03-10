class EspeciesController < ApplicationController

  skip_before_action :set_locale, only: [:create, :update, :edit_photos, :comentarios, :fotos_referencia,
                                         :fotos_naturalista, :bdi_photos, :nombres_comunes_naturalista,
                                         :nombres_comunes_todos, :consulta_registros, :cambia_id_naturalista, :resumen_wikipedia, :descripcion_iucn]

  before_action :set_especie, only: [:show, :edit, :update, :destroy, :edit_photos, :media, :descripcion, :descripcion_app,
                                     :consulta_registros, :cat_tax_asociadas,
                                     :descripcion_catalogos, :comentarios, :bdi_photos,
                                     :fotos_referencia, :fotos_naturalista, :nombres_comunes_naturalista,
                                     :nombres_comunes_todos, :cambia_id_naturalista,
                                     :dame_nombre_con_formato, :noticias, :media_tropicos, :resumen_wikipedia, :descripcion_iucn]

  before_action :authenticate_usuario!, :only => [:new, :create, :edit, :update, :destroy, :destruye_seleccionados, :cambia_id_naturalista]

  before_action :only => [:new, :create, :edit, :update, :destroy, :destruye_seleccionados, :cambia_id_naturalista] do
    tiene_permiso?('Administrador')  # Minimo administrador
  end

  layout false, :only => [:media, :descripcion, :observaciones_naturalista, :edit_photos, :descripcion_catalogos,
                          :comentarios,
                          :fotos_referencia, :bdi_photos, :media_cornell, :xeno_canto, :media_tropicos, :fotos_naturalista, :nombres_comunes_naturalista,
                          :nombres_comunes_todos, :ejemplares_snib, :ejemplar_snib, :observacion_naturalista,
                          :cambia_id_naturalista, :dame_nombre_con_formato, :noticias, :resumen_wikipedia, :descripcion_iucn]

  # Pone en cache el webservice que carga por default
  caches_action :descripcion, :expires_in => eval(CONFIG.cache.fichas), :cache_path => Proc.new { |c| "especies/#{c.params[:id]}/#{c.params[:from]}" }, :if => :params_from_conabio_present?

  # GET /especies
  # GET /especies.json
  def index
    redirect_to root_path
  end

  # GET /especies/1
  # GET /especies/1.json
  def show
    render 'especies/noPublicos' and return unless @especie.scat.Publico
    
    # Para mostrar la taxonomia en la página inicial del show
    @taxones = Especie.arbol_inicial_obligatorias(@especie, 22)

    respond_to do |format|
      format.html do

        @datos = {}
        @datos[:nombre_cientifico] = @especie.nombre_cientifico

        if adicional = @especie.adicional
          @datos[:nombre_comun] =  adicional.nombre_comun_principal
          @datos[:nombres_comunes] =  adicional.nombres_comunes
          @datos[:foto_principal] = adicional.foto_principal
        end

        # Para los geodatos
        geodatos = @especie.consulta_geodatos
        @datos[:geodatos] = geodatos if geodatos[:cuales].any?
          
        # Para saber si es espcie y tiene un ID asociado a NaturaLista
        if proveedor = @especie.proveedor
          naturalista_id = proveedor.naturalista_id
          if naturalista_id.present?
            @datos[:naturalista_api] = "#{CONFIG.inaturalist_api}/taxa/#{naturalista_id}"
            @datos[:ficha_naturalista] = "#{CONFIG.naturalista_url}/observations?locale=es-MX&place_id=6793&preferred_place_id=6793&subview=map&taxon_id=#{naturalista_id}"
          end
        end

        # Para las variables restantes
        @datos[:cuantos_comentarios] = @especie.comentarios.where('comentarios.estatus IN (2,3) AND ancestry IS NULL').count
        @datos[:taxon] = @especie.id
        @datos[:catalogo_id] = @especie.scat.catalogo_id
        @datos[:bdi_api] = "/especies/#{@especie.id}/bdi-photos.json"
        @datos[:cual_ficha] = ''
        @datos[:slug_url] = "/especies/#{@especie.id}-#{@especie.nombre_cientifico.estandariza}"
        @datos[:ancestry] = @especie.ancestry_ascendente_obligatorio
      end

      format.json do
        @especie.e_geodata = []
        geodatos = @especie.consulta_geodatos
        @especie.e_geodata = geodatos if geodatos[:cuales].any?

        @especie.e_nombre_comun_principal = nil
        @especie.e_foto_principal = nil
        @especie.e_nombres_comunes = nil

        if a = @especie.adicional
          @especie.e_nombre_comun_principal = a.nombre_comun_principal
          @especie.e_foto_principal = a.foto_principal
          @especie.e_nombres_comunes = a.nombres_comunes
        end

        @especie.e_categoria_taxonomica = @especie.categoria_taxonomica
        @especie.e_tipo_distribucion = @especie.tipos_distribuciones.uniq
        @especie.e_caracteristicas = @especie.catalogos
        @especie.e_bibliografia = @especie.bibliografias
        @especie.e_fotos = ["#{CONFIG.site_url}especies/#{@especie.id}/bdi-photos.json", "#{CONFIG.site_url}especies/#{@especie.id}/fotos-naturalista.json"]  # TODO: poner las fotos de referencia, actaulmente es un metodo post

        render json: @especie.to_json(methods: [:e_geodata, :e_nombre_comun_principal, :e_foto_principal,
                                                :e_nombres_comunes, :e_categoria_taxonomica, :e_tipo_distribucion,
                                                :e_caracteristicas, :e_bibliografia, :e_fotos])
      end

      format.pdf do
        @fotos = nil

        # Fotos de naturalista
        if p = @especie.proveedor
          fotos = p.fotos_naturalista

          if fotos[:estatus] && fotos[:fotos].any?
            @fotos = []

            fotos[:fotos].each do |f|
              foto = Photo.new
              foto.large_url = f['photo']['large_url']
              foto.medium_url = f['photo']['medium_url']
              foto.native_page_url = f['photo']['native_page_url']
              foto.license = f['photo']['attribution']
              foto.square_url = f['photo']['square_url']
              foto.native_realname = f['photo']['attribution']
              @fotos << foto
            end
          end
        end

        # Fotos de BDI
        unless @fotos.present?
          bdi = @especie.fotos_bdi
          @fotos = bdi.assets if bdi.num_assets > 0
        end

        # Ya tiene la descripcion asignada
        asigna_variables_descripcion

        ruta = Rails.root.join('public', 'pdfs').to_s
        fecha = Time.now.strftime("%Y%m%d%H%M%S")
        pdf = "#{ruta}/#{fecha}_#{rand(1000)}.pdf"
        FileUtils.mkpath(ruta, :mode => 0755) unless File.exists?(ruta)

        render :pdf => @especie.nombre_cientifico.parameterize,
               :object => @photos,
               #:save_to_file => pdf,
               #:save_only => true,
               :wkhtmltopdf => CONFIG.wkhtmltopdf_path,
               :template => 'especies/show.pdf.erb'
        #:encoding => 'UTF-8',
        #:user_style_sheet => 'http://colibri.conabio.gob.mx:4000/assets/application.css'
        #:print_media_type => false,
        #:disable_internal_links => false,
      end
    end
  end

  # GET /especies/new
  def new
    begin
      @especie = Especie.new(:parent_id => params[:parent_id])

      begin
        @parent=Especie.find(params[:parent_id])
        @cat_taxonomica=@parent.categoria_taxonomica.nombre_categoria_taxonomica
      rescue
        respond_to do |format|
          format.html { redirect_to :root, notice: 'Lo sentimos esa página no existe'.html_safe }
        end
      end

    rescue
      respond_to do |format|
        format.html { redirect_to :root, notice: "No existe un grupo o especie con el identificador: #{params[:parent_id]}." }
      end
    end
  end

  # GET /especies/1/edit
  def edit
  end

  # POST /especies
  # POST /especies.json
  def create
    argumentosRelaciones=especie_params
    argumentosRelaciones.delete(:especies_catalogos_attributes)
    argumentosRelaciones.delete(:especies_regiones_attributes)
    argumentosRelaciones.delete(:nombres_regiones_attributes)
    argumentosRelaciones.delete(:nombres_regiones_bibliografias_attributes)
    @especie = Especie.new(argumentosRelaciones)
    ascendete=Especie.find(argumentosRelaciones[:parent_id])
    @especie.ancestry_ascendente_obligatorio="#{ascendete.ancestry_ascendente_obligatorio}/#{ascendete.id}"

    respond_to do |format|
      if @especie.save && params[:commit].eql?('Crear')
        descripcion="Creó un nuevo taxón(#{@especie.id}): #{@especie.categoria_taxonomica.nombre_categoria_taxonomica} ✓ #{@especie.nombre_cientifico}"
        bitacora=Bitacora.new(:descripcion => descripcion, :usuario_id => current_usuario.id)
        bitacora.save
        guardaRelaciones(EspecieCatalogo)
        guardaRelaciones(EspecieRegion)
        format.html { redirect_to @especie, notice: "El taxón #{@especie.nombre_cientifico} fue creado exitosamente." }
        format.json { render action: 'show', status: :created, location: @especie }
      elsif @especie.save && params[:commit].eql?('Crear y seguir editando')
        descripcion="Creó un nuevo taxón: #{@especie.categoria_taxonomica.nombre_categoria_taxonomica} ✓ #{@especie.nombre_cientifico}"
        bitacora=Bitacora.new(:descripcion => descripcion, :usuario_id => current_usuario.id)
        bitacora.save
        guardaRelaciones(EspecieCatalogo)
        guardaRelaciones(EspecieRegion)
        format.html { redirect_to "/especies/#{@especie.id}/edit", notice: "El taxón #{@especie.nombre_cientifico} fue creado exitosamente." }
      else
        format.html { render action: 'new' }
        format.json { render json: @especie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /especies/1
  # PATCH/PUT /especies/1.json
  def update
    guardaRelaciones(EspecieCatalogo)
    guardaRelaciones(EspecieRegion)
    guardaRelaciones(NombreRegion)
    guardaRelaciones(NombreRegionBibliografia)

    respond_to do |format|
      argumentosRelaciones=especie_params
      argumentosRelaciones.delete(:especies_catalogos_attributes)
      argumentosRelaciones.delete(:especies_regiones_attributes)
      argumentosRelaciones.delete(:nombres_regiones_attributes)
      argumentosRelaciones.delete(:nombres_regiones_bibliografias_attributes)

      if @especie.update(argumentosRelaciones) && params[:commit].eql?('Guardar')
        descripcion="Actualizó el taxón #{@especie.nombre_cientifico} (#{@especie.id})"
        bitacora=Bitacora.new(:descripcion => descripcion, :usuario_id => current_usuario.id)
        bitacora.save
        format.html { redirect_to @especie, notice: "El taxón #{@especie.nombre_cientifico} fue modificado exitosamente." }
        format.json { head :no_content }
      elsif @especie.update(argumentosRelaciones) && params[:commit].eql?('Guardar y seguir editando')
        descripcion="Actualizó el taxón #{@especie.nombre_cientifico} (#{@especie.id})"
        bitacora=Bitacora.new(:descripcion => descripcion, :usuario_id => current_usuario.id)
        bitacora.save
        #format.html { render action: 'edit' }
        format.html { redirect_to "/especies/#{@especie.id}/edit", notice: "El taxón #{@especie.nombre_cientifico} fue modificado exitosamente." }
        #else
        #format.html { render action: 'edit' }
        #format.json { render json: @especie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /especies/1
  # DELETE /especies/1.json
  def destroy
    @especie.destroy
    bitacora=Bitacora.new(:descripcion => "Eliminó al taxón #{@especie.nombre_cientifico} (#{@especie.id})", :usuario_id => current_usuario.id)
    bitacora.save
    respond_to do |format|
      format.html { redirect_to especies_index_path, :notice => "El taxón #{@especie.nombre_cientifico} fue elimanado correctamente" }
      format.json { head :no_content }
    end
  end

  # REVISADO: Regresa el nombre cientifico con el formato del helper, lo uso mayormente en busquedas por 
  def dame_nombre_con_formato
    render html: "#{helpers.tituloNombreCientifico(@especie, render: 'link')}".html_safe
  end

  # Las fotos en el carrusel inicial, provienen de las fotos de referencia de naturalista o de bdi
  def fotos_referencia
    @fotos = []

    JSON.parse(params['fotos']).each do |foto|
      f = foto['photo'].present? ? foto['photo'] : foto
      f_obj = Photo.new
      f_obj.native_page_url = f['native_page_url']
      f_obj.medium_url = f['medium_url']
      f_obj.large_url = f['large_url']
      f_obj.square_url = f['square_url']
      attrib = f['attribution'].present? ? f['attribution'] : "#{f['native_realname']}, #{f['license'].match('/licenses\/(.*?)\/')[1].upcase}"
      f_obj.attribution_txt = attrib
      f_obj.original_url = f['original_url']
      @fotos << f_obj
    end

    @foto_default = @fotos.first
  end

  # Acción necesaria para la tab media, similar a describe ¬¬
  def media
    render 'especies/media/media'
  end

  # Servicio de lib/bdi_service.rb
  def bdi_photos
    bdi = @especie.fotos_bdi({album: params[:album]})

    respond_to do |format|
      format.json do
        if params[:api] == "1" && bdi.num_assets == 0 # Si viene de la API y NO hay resultados
          jres = {estatus: false, msg: "No se encontraron fotos en el Banco de imágenes de CONABIO."}
          render json: jres
        elsif params[:api] == "1" # Si hay resultados pero viene de la API 
          jres = bdi.assets.map{|f| { thumb_url: f.medium_url, large_url: f.large_url, atribucion: "#{f.native_realname}, BDI - CONABIO" } }
          render json: jres
        else # Si NO viene de la API
          render json: { fotos: bdi.assets, albumes: bdi.albumes, num_fotos: bdi.num_assets } 
        end
      end
      format.html do
        @fotos = bdi.assets
        @albumes = bdi.albumes
        @num_fotos = bdi.num_assets

        # Caso especicial para el icono de usos
        type = params[:album].present? && params[:album] == "usos" ? "usos" : "photo"

        render 'especies/media/bdi_photos', locals: { type: type }
      end  # End format html
    end  # End respond
  end

  #servicio Macaulay Library (eBird)
  def media_cornell
    type = params['type']
    page = params['page']
    taxonNC = Especie.find(params['id']).nombre_cientifico
    mc = MacaulayService.new
    @array = mc.dameMedia_nc(taxonNC, type, page)

    respond_to do |format|
      format.html do
        render 'especies/media/media_cornell', :locals => {type: type, page: page}
      end

      format.json do
        if @array.length == 1 && @array[0][:msg].present? # Esta vacio
          jres = {estatus: false, msg: "No hay imagenes en Macaulay Library."}
        else
          if params[:type] == "photo"
            jres = @array.map{|f| { thumb_url: "#{f["mlBaseDownloadUrl"]}#{f["assetId"]}/320", large_url: "#{f["mlBaseDownloadUrl"]}#{f["assetId"]}/900", atribucion: "#{f["userDisplayName"]}, Macaulay Library" }}
          elsif params[:type] == "video"
            jres = @array.map{|f| { thumb_url: "#{f["mlBaseDownloadUrl"]}#{f["assetId"]}/thumb", video_url: "#{f["mlBaseDownloadUrl"]}#{f["assetId"]}/video", atribucion: "#{f["userDisplayName"]}, Macaulay Library" }}
          elsif params[:type] == "audio"
            jres = @array.map{|f| { thumb_url: "#{f["mlBaseDownloadUrl"]}#{f["assetId"]}/poster", audio_url: "#{f["mlBaseDownloadUrl"]}#{f["assetId"]}/audio", atribucion: "#{f["userDisplayName"]}, Macaulay Library" }}            
          end
        end

        render json: jres
      end
    end
  end

  #Servicio Xeno-Canto
  def xeno_canto
    type = params['type']
    taxon = Especie.find(params['id']).nombre_cientifico
    xeno_c = XenoCantoService.new
    @cantos = xeno_c.obtener_cantos(taxon)

    respond_to do |format|
      format.html do
        render 'especies/media/xeno_canto', :locals => {type: type}
      end

      format.json do
        if @cantos.length == 1 && @cantos[0][:msg].present? # Esta vacio
          jres = {estatus: false, msg: "No hay imagenes en Xeno-Canto."} 
        else
          jres = @cantos.map{|c| { thumb_url: "https:#{c["sono"]["med"]}", audio: c["file"], atribucion: "#{c["rec"]}, Xeno-Canto" } }
        end

        render json: jres
      end
    end    
  end

  # Servicio Tropicos
  def media_tropicos
    type = params['type']
    page = params['page']

    # Crear instancia de servicio trópicos:
    ts_req = Tropicos_Service.new

    # Para saber si tiene proveedor asociado
    prov = @especie.proveedor
    if prov.present?

      # Verificar si tiene ya el tropico_id (si se consultó anteriormente)
      tropico_id = prov.tropico_id
      if tropico_id.present?

        # Si existe el tropico_id, recuperar las imágenes
        @array = ts_req.get_media(tropico_id)

      else
        # No existe aún el tropico_id, buscarlo invocando el servicio:
        @name_id = ts_req.get_id_name(@especie.nombre_cientifico)

        if @name_id[0][:msg].present?
          # Si no existió la especie: mostrar mensaje generado
          @array = [{estatus: false, msg: "Hubo un error: #{@name_id[0][:msg]}"}]

        else
          # Si existió la especie:
          prov.update(tropico_id: @name_id[0]['NameId'])
          #Una vez obtenido el id de la especie, recuperar las imágenes
          @array = ts_req.get_media(@name_id[0]['NameId'])
        end
      end

    else
      # No existe aún la especie en proveedores ni el tropico_id, buscarlo invocando el servicio:
      @name_id = ts_req.get_id_name(@especie.nombre_cientifico)

      if @name_id[0][:msg].present?
        # Si no existió la especie: mostrar mensaje generado
        @array = [{estatus: false, msg: "Hubo un error: #{@name_id[0][:msg]}"}]

      else
        # Si existió la especie:
        Proveedor.create(especie_id: @especie.id, tropico_id: @name_id[0]['NameId'])
        #Una vez obtenido el id de la especie, recuperar las imágenes
        @array = ts_req.get_media(@name_id[0]['NameId'])
      end
    end

    respond_to do |format|
      format.html do
        @array = [{msg: "Aún no hay imágenes para esta especie :/ "}] if @array[0]["Error"].present?
        render 'especies/media/media_tropicos', :locals => {type: type, page: page}
      end

      format.json do
        if @array[0]["Error"].present? || (@array.length == 1 && @array[0][:msg].present?) # No hay imagenes
          @array = {estatus: false, msg: "No hay imagenes en Tropicos."} 
          render json: @array
        else
          jres = @array.map{|f| { thumb_url: f["DetailJpgUrl"], large_url: f["DetailJpgUrl"], atribucion: "#{f["Copyright"]}, Tropicos" } }
          render json: jres
        end
        
      end
    end      


  end

  def fotos_naturalista
    fotos = if p = @especie.proveedor
              p.fotos_naturalista
            else
              {estatus: false, msg: 'No hay resultados por nombre científico en naturalista'}
            end

    if fotos.nil? && params[:api] == "1" # Si viene de la API y no tiene fotos
      jres = { estatus: false, msg: "No hay fotos en Naturalista." }
      render json: jres
    elsif params[:api] == "1" && fotos[:estatus]
      jres = fotos[:ficha]["taxon_photos"][0..9].map{ |f| { thumb_url: f["photo"]["medium_url"], large_url: f["photo"]["large_url"], atribucion: "#{f["photo"]["attribution"]}, Naturalista" } }
      render json: jres
    else
      render json: fotos
    end        
  end

  def nombres_comunes_naturalista
    nombres_comunes = if p = @especie.proveedor
                        p.nombres_comunes_naturalista
                      else
                        {estatus: false, msg: 'No hay resultados por nombre científico en naturalista'}
                      end

    render json: nombres_comunes
  end

  def nombres_comunes_todos
    @nombres_comunes = @especie.dame_nombres_comunes_todos
  end

  # Viene de la pestaña "Acerca de " de la ficha
  def descripcion
    asigna_variables_descripcion
    if @descripcion.blank? && @api == 'conabio_inat'
      render plain: "<div></div>"
    else
      render 'especies/descripciones/descripcion'
    end
  end

  # La respuesta a la ficha en la app
  def descripcion_app
    asigna_variables_descripcion(true)
    render 'especies/descripciones/descripcion_app', layout: 'descripcion_app'
  end

  # Regresa el resumen de wikipedia en español o ingles
  def resumen_wikipedia
    opc = { taxon: @especie, locale: params[:locale] }

    if params[:locale].present?
      resumen = Api::Wikipedia.new(opc).resumen
    else
      resumen = Api::Wikipedia.new(opc).resumen_cualquiera
    end

    render json: { estatus: (resumen.present? ? true : false), sumamry: resumen }
  end
    
  # Viene de la pestaña de la ficha
  def descripcion_catalogos
    if params[:app]
      render 'especies/descripciones/descripcion_catalogos_app'
    else
      render 'especies/descripciones/descripcion_catalogos'
    end
  end

  # La descripcion proveniente de IUCN redlist
  def descripcion_iucn
    iucn = IUCNService.new
    iucn.taxon = @especie
    iucn.encuentra_descripcion

    @campos = [['geographicrange', 'Geographic Range'], ['habitat', 'Habitat'], ['population', 'Population'], ['populationtrend', 'Population Trend'], ['usetrade', 'Use and Trade'], ['threats', 'Threats'], ['conservationmeasures', 'Conservation Measures'], ['rationale', 'Rationale'], ['taxonomicnotes', 'Taxonomic Notes']]

    @descripcion = iucn.datos
    render 'especies/descripciones/descripcion_iucn'
  end

  # Descarga los registros de naturalista, snib y en el formato solicitado. Tambien se incluye para el app
  def consulta_registros
    if params[:coleccion].present? && params[:formato].present?
      respond_to do |format|
        @especie.coleccion = params[:coleccion]
        @especie.formato = params[:formato]
        @especie.descarga_registros

        format.json do
          headers['Access-Control-Allow-Origin'] = '*'
          headers['Access-Control-Allow-Methods'] = 'GET'
          headers['Access-Control-Request-Method'] = '*'
          headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
          
          if @especie.jres[:estatus]
            if params[:formato] == 'json'
              archivo = File.read(@especie.jres[:ruta_archivo])
              send_data archivo, :filename => @especie.jres[:ruta_archivo].split('/').last
            elsif params[:formato] == 'mapa-app'
              render json: @especie.jres[:registros]
            else
              render json: { estatus: false, msg: 'Parámetros incorrectos' }
            end
          else
            render json: @especie.jres
          end
        end

        format.kml do
          if @especie.jres[:estatus]
            archivo = File.read(@especie.jres[:ruta_archivo])
            send_data archivo, :filename => @especie.jres[:ruta_archivo].split('/').last
          else
            render json: @especie.jres
          end
        end

        format.kmz do
          if @especie.jres[:estatus]
            archivo = File.read(@especie.jres[:ruta_archivo])
            send_data archivo, :filename => @especie.jres[:ruta_archivo].split('/').last
          else
            render json: @especie.jres
          end
        end

      end  # End respond_to
    else
      render json: { estaus: false, msg: 'Parámetros incorrectos' }
    end
  end

  # Muestra los comentarios relacionados a la especie, viene de la ficha de la especie
  def comentarios
    @comentarios = Comentario.datos_basicos.where(especie_id: @especie).where('comentarios.estatus IN (2,3) AND ancestry IS NULL').order('comentarios.created_at DESC')

    @comentarios.each do |c|
      c.cuantos = c.descendants.count
      c.completa_info((c.usuario_id if c.is_root?))
    end
  end

  #muestra las noticias de google Noticias ¬¬
  def noticias
    require 'rss'

    #xml = HTTParty.get("https://news.google.com/news?q=#{@especie.nombre_cientifico.limpiar}&output=rss").body
    #xml = Nokogiri::XML(open("https://news.google.com/news?q=#{@especie.nombre_cientifico.limpiar}&output=rss"))
    url = "https://news.google.com/news?q=#{@especie.nombre_cientifico.limpiar}&output=rss&hl=es-419&gl=MX&ceid=MX:es-419"
    @noticias = ''
    open(url) do |rss|
      @noticias = RSS::Parser.parse(rss)
    end
  end

  def cambia_id_naturalista
    new_id = params[:new_url].gsub(/\D/, '').to_i
    if p = @especie.proveedor
      # existe proveedor'
      p.naturalista_id = new_id
    else
      # NO existe proveedor
      p = Proveedor.new({especie_id: @especie.id,naturalista_id: new_id})
    end

    if p.changed? && p.save
      # cambio, y salvó
      @especie.borra_cache('observaciones_naturalista') if @especie.existe_cache?('observaciones_naturalista')
      redirect_to especie_path(@especie), notice: 'El cambio fue exitoso, puede que tarde un poco en lo que se actualiza el cache'
    else
      # no cambio y no salvó
      redirect_to especie_path(@especie), notice: 'No se logro el cambio, el id era el mismo, hubo un error en la url proporcionada, contactar programadores con pantallazo.'
    end
  end


  def show_bioteca_record_info

    # Variable fianl que contendrá los detalles de X ficha seleccionada
    @detalle_ficha_janium
    @status_detalle_ficha_janium = false
    @etiquetas = {}

    # Crear el cliente Savon
    client = Savon.client(
        endpoint: CONFIG.janium.location,
        namespace: CONFIG.janium.namespace,
        ssl_version: :TLSv1,
        pretty_print_xml: true
    )

    request_message = {
        :method => "RegistroBib/Detalle",
        :arg => {
            a: "ficha",
            v: params[:id]
        }
    }

    # Invocar el servicio web
    begin
      # La respuesta será un SAVON response
      response = client.call(CONFIG.janium.request, soap_action: "#{CONFIG.janium.namespace}##{CONFIG.janium.request}", message: request_message)

      # La respuesta pasa a ser un XML
      doc = Nokogiri::XML.parse(response.to_xml)

      # Extraemos el estatus de la respuesta
      @status_detalle_ficha_janium = doc.xpath('//soap:status', 'soap' => CONFIG.janium.namespace).text
      # Extraer el padre etiquetas
      @detalle_ficha_janium = Nokogiri::XML(doc.xpath('//soap:etiquetas', 'soap' => CONFIG.janium.namespace).to_s)
      @url_detalle_ficha_janium = doc.xpath('//soap:url_asociada', 'soap' => CONFIG.janium.namespace).text

      # Si el estatus es 'OK'
      if @status_detalle_ficha_janium
        # Iterar las etiquetas y extraer los titulos y textos
        @detalle_ficha_janium.xpath("//etiquetas/etiqueta").each do |etiqueta|
          content = Nokogiri::XML(etiqueta.to_s)
          titulo = content.xpath("//etiqueta/etiqueta").text
          texto = content.xpath("//etiqueta/texto").text
          if @etiquetas[titulo].nil?
            @etiquetas[titulo] = []
            @etiquetas[titulo] << texto
          else
            @etiquetas[titulo] << texto
          end
        end
      end

      Rails.logger.debug "[DEBUG] La ficha final es: #{doc}"

    rescue => ex
      # Si surge un error durante la invocación al WS, @registros_janium quedará vacío
      @status_detalle_ficha_janium = false
      logger.error ex.message
    end

    respond_to do |format|
      format.html {
        render :partial => 'bioteca_info_record'
      }
    end
  end

  # Función que invocará al servicio web "Janium"
  def show_bioteca_records

    # Variable que contendrá todas las respuestas para la vista
    @bioteca_response = {}

    # Crear el cliente Savon
    client = Savon.client(
        endpoint: CONFIG.janium.location,
        namespace: CONFIG.janium.namespace,
        ssl_version: :TLSv1,
        pretty_print_xml: true
    )

    # Invocar el servicio web
    begin
      # En la url, se recibe el id de la especie, se procede a buscarlo
      especie = Especie.find(params[:id])

      # Extraer nombres
      @bioteca_response = {
          :id => especie.id,
          :nombre => {
              "comun" => especie.adicional.nombre_comun_principal,
              "cientifico" => especie.nombre_cientifico
          },
          :tipo_busqueda_actual => params[:t_name].present? ? params[:t_name] : "cientifico" # Por default, buscará por nombre científico
      }

      # Recuperar parámetro de paginado
      params[:n_page].present? ? @bioteca_curent_page = params[:n_page].to_i : @bioteca_curent_page = 1

      # Crear la solicitud (el mensaje) para generar un soap request
      request_message = {
          :method => "RegistroBib/BuscarPorPalabraClaveGeneral",
          :arg => {
              a: "terminos",
              v: @bioteca_response[:nombre][@bioteca_response[:tipo_busqueda_actual]]
          },
          :arg2 => {
              a: "numero_de_pagina",
              v: @bioteca_curent_page
          }
      }

      # La respuesta será un SAVON response
      response = client.call(CONFIG.janium.request, soap_action: "#{CONFIG.janium.namespace}##{CONFIG.janium.request}", message: request_message)

      # La respuesta pasa a ser un XML
      doc = Nokogiri::XML.parse(response.to_xml)

      # Extraer el estatus de la consulta:
      @bioteca_response[:status_fichas] = doc.xpath('//soap:status', 'soap' => CONFIG.janium.namespace).text

      if @bioteca_response[:status_fichas] = 'ok'
        @bioteca_response[:registros_janium] = []
        @registros_janium = []
        # Extraer los registros:
        @bioteca_response[:registros_fichas_janium] = doc.xpath('//soap:total_de_registros', 'soap' => CONFIG.janium.namespace).text.to_i
        @bioteca_response[:registros_x_pagina_janium] = doc.xpath('//soap:registros_por_pagina', 'soap' => CONFIG.janium.namespace).text.to_i

        # Iterar registros registros
        doc.xpath('//soap:registro', 'soap' => CONFIG.janium.namespace).each do |registro|
          @bioteca_response[:registros_janium] << Nokogiri::XML(registro.to_s)
          #Rails.logger.debug "[DEBUG] registro agregado: #{@registros_janium.last.xpath("//titulo").text}"
        end
      else
        @bioteca_response[:status_fichas] = 'error'
      end

    rescue => ex
      # Si surge un error durante la invocación al WS, @registros_janium quedará vacío
      @bioteca_response[:status_fichas] = 'error'
      @bioteca_response[:registros_fichas_janium] = 0
      logger.error ex.message
    end

    # Si hay fichas que mostrar:
    if @bioteca_response[:registros_fichas_janium] > 0
      # Mostrar las páginas sólo si la pagina solicitada es nula (la 1) ( como la base)
      !params[:n_page].present? || params[:n_page] == '1' ? @show_pagination = true : @show_pagination = false
      !params[:n_page].present? && !params[:t_name].present? ? @show_find_by = true : @show_find_by = false
      # Responder con la plantilla hecha
      respond_to do |format|
        format.html {
          render :partial => 'bioteca_records'
        }
      end
    else
      render plain: nil
    end
  end


  private

  def set_especie
    id = params[:id].split('-').first

    if id.numeric?  # Quiere decir que es un ID de la centralizacion o del antiguo de millones
      begin
        @especie = Especie.find(id)  # Coincidio y es el ID de la centralizacion
      rescue
        id_millon = Adicional.where(idMillon: id).first
        @especie = Especie.find(id_millon.especie_id) if id_millon  # Es el ID viejo de millones
      end

    elsif idCAT = Scat.where(catalogo_id: id).first
      @especie = idCAT.especie  # Es el IdCAT de la tabla SCAT
    end

    unless @especie.present?
      if params[:action] == 'show' && params[:format] == 'json'
        render json: {} and return
      else
        render :_error and return
      end
    end
    
    # seteo pedir el taxon valido ANTES de correr los servicios debido a que debo actualizar el valido en vez del sinonimo
    @especie = @especie.dame_taxon_valido

    # Si llego aqui quiere decir que encontro un id en la centralizacion valido
    @especie.servicios if params[:action] == 'show' && params[:format].blank?

    render :_error and return unless @especie

    if params[:action] == 'resultados'  # Mando directo al valido, por si viene de resulados
      redirect_to especie_path(@especie) and return
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def especie_params
    params.require(:especie).permit(:nombre, :estatus, :fuente, :nombre_autoridad, :numero_filogenetico,
                                    :cita_nomenclatural, :sis_clas_cat_dicc, :anotacion, :categoria_taxonomica_id, :parent_id,
                                    especies_catalogos_attributes: [:id, :observaciones, :catalogo_id, :_destroy],
                                    especies_regiones_attributes: [:id, :observaciones, :region_id, :tipo_distribucion_id, :_destroy],
                                    nombres_regiones_attributes: [:id, :observaciones, :region_id, :nombre_comun_id, :_destroy],
                                    nombres_regiones_bibliografias_attributes: [:id, :observaciones, :region_id, :nombre_comun_id, :bibliografia_id, :_destroy]
    )
  end

  def asigna_variables_descripcion(app=false)
    if params[:from].present?
      begin
        desc = eval("Api::#{params[:from].camelize}")
        @descripcion = desc.new(taxon: @especie, app: app).dame_descripcion
        @api = params[:from]
      rescue => e
        Rails.logger.info e.inspect
      end
    else
      begin
        desc = Api::Descripcion.new(taxon: @especie, app: app).dame_descripcion
        @descripcion = desc[:descripcion]
        @api = desc[:api]
      rescue => e
        Rails.logger.info e.inspect
      end
    end
  end

  def guardaRelaciones(tipoRelacion)
    contadorRelacion=0;
    nombreRelacion=tipoRelacion.to_s.tableize.pluralize
    relacion=Hash.new
    relacionNuevos=Hash.new

    if especie_params.has_key?("#{nombreRelacion}_attributes")
      especie_params["#{nombreRelacion}_attributes"].each do |key, value|

        relacion[contadorRelacion]=value
        contadorRelacion+=1
      end

      for rel in 0..relacion.size-1
        if relacion[rel].has_key?(:id) && relacion[rel][:_destroy].blank?
          begin
            @especie.send(nombreRelacion).where(valoresRelacion(tipoRelacion.to_s, relacion[rel], false, true)).first.update(valoresRelacion(tipoRelacion.to_s, relacion[rel]))
          rescue
          end

        elsif relacion[rel].has_key?(:id) && relacion[rel][:_destroy].present?
          begin
            criterio=valoresRelacion(tipoRelacion.to_s, relacion[rel], false, true)
            @especie.send(nombreRelacion).where(criterio).first.delete
            descripcion="Eliminó la relación #{nombreRelacion} del taxón #{@especie.nombre_cientifico} (#{@especie.id})"
            criterio.each do |atributo, valor|
              descripcion+=", caracteristica del taxón: #{Catalogo.find(valor).descripcion} (#{valor})" if atributo == :catalogo_id
              descripcion+=", región: #{Region.find(valor).nombre_region} (#{valor})" if atributo == :region_id
              descripcion+=", nombre común: #{NombreComun.find(valor).nombre_comun} (#{valor})" if atributo == :nombre_comun_id
              descripcion+=", bibliografía: #{Bibliografia.find(valor).autor.truncate(25)} (#{valor})" if atributo == :bibliografia_id
            end
            bitacora=Bitacora.new(:descripcion => descripcion, :usuario_id => current_usuario.id)
            bitacora.save
          rescue
          end
        else
          relacionNuevos ||=Hash.new
          relacionNuevos[rel]=valoresRelacion(tipoRelacion.to_s, relacion[rel], true)
        end
      end

      if relacionNuevos
        relacionNuevos.each do |key, value|
          nuevo=tipoRelacion.new(value)
          begin
            if nuevo.save
              descripcion="Agrego una nueva relación de #{nombreRelacion} al taxón: #{@especie.nombre_cientifico} (#{@especie.id})"
              value.each do |atributo, valor|
                descripcion+=", caracteristica del taxón: #{Catalogo.find(valor).descripcion} (#{valor})" if atributo == :catalogo_id
                descripcion+=", región: #{Region.find(valor).nombre_region} (#{valor})" if atributo == :region_id
                descripcion+=", tipo de distribución: #{TipoDistribucion.find(valor).descripcion} (#{valor})" if atributo == :tipo_distribucion_id
                descripcion+=", nombre común: #{NombreComun.find(valor).nombre_comun} (#{valor})" if atributo == :nombre_comun_id
                descripcion+=", bibliografía: #{Bibliografia.find(valor).autor.truncate(25)} (#{valor})" if atributo == :bibliografia_id
                descripcion+=", observaciones: #{valor}" if atributo == :observaciones
              end
              bitacora=Bitacora.new(:descripcion => descripcion, :usuario_id => current_usuario.id)
              bitacora.save
            end
          rescue
          end
        end
      end

    end
  end

  def valoresRelacion(tipoRelacion, atributos, nuevo=false, criterio=false)
    case tipoRelacion
    when 'EspecieCatalogo'
      if criterio
        condicion=atributos[:id].delete('[').delete(']').delete('"').split(',')
        {:catalogo_id => condicion[1].strip.to_i}
      else
        nuevo ? {:especie_id => @especie.id, :catalogo_id => atributos[:catalogo_id], :observaciones => atributos[:observaciones]} :
            {:catalogo_id => atributos[:catalogo_id], :observaciones => atributos[:observaciones]}
      end

    when 'EspecieRegion'
      if criterio
        condicion=atributos[:id].delete('[').delete(']').delete('"').split(',')
        {:region_id => condicion[1].strip.to_i}
      else
        nuevo ? {:especie_id => @especie.id, :region_id => atributos[:region_id], :tipo_distribucion_id => atributos[:tipo_distribucion_id],
                 :observaciones => atributos[:observaciones]} :
            {:region_id => atributos[:region_id], :tipo_distribucion_id => atributos[:tipo_distribucion_id],
             :observaciones => atributos[:observaciones]}
      end

    when 'NombreRegion'
      region ||=''
      especie_params[:especies_regiones_attributes].each do |key, value|
        if value.has_key?(:id)
          id=value[:id].delete('[').delete(']').delete('"').split(',')
          probableRegion=id[1].strip.to_i
          region=value[:region_id] if probableRegion==atributos[:region_id].to_i
        end
      end

      if criterio
        condicion=atributos[:id].delete('[').delete(']').delete('"').split(',')
        {:region_id => region, :nombre_comun_id => condicion[2].strip.to_i}
      else
        nuevo ? {:especie_id => @especie.id, :region_id => region, :nombre_comun_id => atributos[:nombre_comun_id],
                 :observaciones => atributos[:observaciones]} :
            {:nombre_comun_id => atributos[:nombre_comun_id], :observaciones => atributos[:observaciones]}
      end

    when 'NombreRegionBibliografia'
      region ||=''
      especie_params[:especies_regiones_attributes].each do |key, value|
        if value.has_key?(:id)
          id=value[:id].delete('[').delete(']').delete('"').split(',')
          probableRegion=id[1].strip.to_i
          region=value[:region_id] if probableRegion==atributos[:region_id].to_i
        end
      end

      nombre ||=''
      especie_params[:nombres_regiones_attributes].each do |key, value|
        if value.has_key?(:id)
          id=value[:id].delete('[').delete(']').delete('"').split(',')
          probableNombre=id[2].strip.to_i
          nombre=value[:nombre_comun_id] if probableNombre==atributos[:nombre_comun_id].to_i
        end
      end

      if criterio
        condicion=atributos[:id].delete('[').delete(']').delete('"').split(',')
        {:region_id => region, :nombre_comun_id => nombre, :bibliografia_id => condicion[3].strip.to_i}
      else
        nuevo ? {:especie_id => @especie.id, :region_id => region, :nombre_comun_id => nombre,
                 :bibliografia_id => atributos[:bibliografia_id], :observaciones => atributos[:observaciones]} :
            {:bibliografia_id => atributos[:bibliografia_id], :observaciones => atributos[:observaciones]}
      end
    end
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

  # Este método es necesario para ver params antes de que se inicialice dicha variable (caches_action corre antes q eso)
  def params_from_conabio_present?
    Rails.env.production? && params.present? && params[:from].present? && !params[:from].include?('conabio')
  end

end
