class EspeciesController < ApplicationController

  skip_before_filter :set_locale, only: [:kmz, :kmz_naturalista, :create, :update, :edit_photos]
  before_action :set_especie, only: [:show, :edit, :update, :destroy, :edit_photos, :update_photos, :describe,
                                     :datos_principales, :kmz, :kmz_naturalista, :cat_tax_asociadas]
  before_action :only => [:arbol, :arbol_inicial, :json_d3, :nodo_json_d3] do
    set_especie(true)
  end

  before_action :authenticate_usuario!, :only => [:new, :create, :edit, :update, :destroy, :destruye_seleccionados]
  before_action :only => [:new, :create, :edit, :update, :destroy, :destruye_seleccionados] do
    permiso = tiene_permiso?(100)  # Minimo administrador
    render :_error unless permiso
  end

  layout false, :only => [:describe, :arbol, :datos_principales, :kmz, :kmz_naturalista, :edit_photos, :json_d3, :nodo_json_d3]

  # Pone en cache el webservice que carga por default
  caches_action :describe, :expires_in => 1.week, :cache_path => Proc.new { |c| "especies/#{c.params[:id]}/#{c.params[:from]}" }

  #c.session.blank? || c.session['warden.user.user.key'].blank?
  #}
  #cache_sweeper :taxon_sweeper, :only => [:update, :destroy, :update_photos]

  # GET /especies
  # GET /especies.json
  #def index
  #end

  # GET /especies/1
  # GET /especies/1.json
  def show
    # Esto es para mostrar primero las fotos de NaturaLista, despues las de CONABIO
    fotos_naturalista = @especie.photos.where.not(type: 'ConabioPhoto').where("medium_url is not null or large_url is not null or original_url is not null")
    fotos_conabio = @especie.photos.where(type: 'ConabioPhoto').where("medium_url is not null or large_url is not null or original_url is not null")
    @photos = [fotos_naturalista, fotos_conabio].flatten.compact

    respond_to do |format|
      format.html do
        @especie.delayed_job_service

        # Para saber si es espcie y tiene un ID asociado a NaturaLista
        if @especie.species_or_lower?
          if proveedor = @especie.proveedor
            @con_naturalista = proveedor.naturalista_id if proveedor.naturalista_id.present?
          end
        end
      end
      format.json { render json: @especie.to_json }
      format.kml do
        redirect_to(especie_path(@especie), :notice => t(:el_taxon_no_tiene_kml)) unless proveedor = @especie.proveedor

        if params[:snib].present? && to_boolean(params[:snib])
          redirect_to(especie_path(@especie), :notice => t(:el_taxon_no_tiene_kml)) unless proveedor.snib_kml
          send_data @especie.proveedor.snib_kml, :filename => "#{@especie.nombre_cientifico}.kml"
        elsif params[:naturalista].present? && to_boolean(params[:naturalista])
          redirect_to(especie_path(@especie), :notice => t(:el_taxon_no_tiene_kml)) unless proveedor.naturalista_kml
          send_data @especie.proveedor.naturalista_kml, :filename => "#{@especie.nombre_cientifico}.kml"
        else
          redirect_to especie_path(@especie), :notice => t(:el_taxon_no_tiene_kml)
        end
      end

      format.pdf do
        # wicked_pdf no admite request en ajax, lo llamamos directo antes del view
        @describers = if CONFIG.taxon_describers
                        CONFIG.taxon_describers.map{|d| TaxonDescribers.get_describer(d)}.compact
                      elsif @especie.iconic_taxon_name == "Amphibia" && @especie.species_or_lower?
                        [TaxonDescribers::Wikipedia, TaxonDescribers::AmphibiaWeb, TaxonDescribers::Eol]
                      else
                        [TaxonDescribers::Wikipedia, TaxonDescribers::Eol]
                      end


        @describers.each do |d|
          @describer = d
          @description = begin
            d.equal?(TaxonDescribers::EolEs) ? d.describe(@especie, :language => 'es') : d.describe(@especie)
          rescue OpenURI::HTTPError, Timeout::Error => e
            nil
          end
          break unless @description.blank?
        end

        ruta = Rails.root.join('public', 'pdfs').to_s
        fecha = Time.now.strftime("%Y%m%d%H%M%S")
        pdf = "#{ruta}/#{fecha}_#{rand(1000)}.pdf"
        FileUtils.mkpath(ruta, :mode => 0755) unless File.exists?(ruta)

        render :pdf => @especie.nombre_cientifico.parameterize,
               #:save_to_file => pdf,
               #:save_only => true,
               :wkhtmltopdf => CONFIG.wkhtmltopdf_path,
               :template => 'especies/show.pdf.erb',
               #:encoding => 'UTF-8',
               :user_style_sheet => 'http://bios.conabio.gob.mx/assets/application.css'
               #:print_media_type => false,
               #:disable_internal_links => false,
               #


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

  # Despliega o contrae o muestra el arbol de un inicio
  def arbol
    @despliega_o_contrae = to_boolean(params[:accion]) if params[:accion].present?
    nodos_arbol
  end

  # Muestra el arbol en una sola pagina
  def arbol_inicial
    #@especie = nil
    #@despliega_o_contrae = false
    #nodos_arbol
  end

  # JSON que se ocupara para desplegar los datos en D3
  def json_d3
    json_d3 = genera_obj_d3
    render :json => json_d3.to_json
  end

  # JSON que despliega solo un nodo con sus hijos, para pegarlos en json ya construido con d3
  def nodo_json_d3
    children_array = []
    taxones = Especie.select_basico.datos_basicos.caso_rango_valores('especies.id',@especie.child_ids.join(',')).order_por_categoria('DESC')

    taxones.each do |t|
      children_hash = asigna_hash_d3(t)

      # Acumula el resultado del json anterior una posicion antes de la actual
      children_array << children_hash
    end

    render :json => children_array.to_json
  end

  def edit_photos
    @photos = @especie.taxon_photos.sort_by{|tp| tp.id}.map{|tp| tp.photo}
  end

  def update_photos
    photos = retrieve_photos
    errors = photos.map do |p|
      p.valid? ? nil : p.errors.full_messages
    end.flatten.compact

    @especie.photos = photos
    @especie.save

    #unless photos.count == 0
    #  Especie.delay(:priority => INTEGRITY_PRIORITY).update_ancestor_photos(@especie.id, photos.first.id)
    #end
    if errors.blank?
      flash[:notice] = 'Las fotos fueron actualizadas satisfactoriamente'
    else
      flash[:error] = "Algunas fotos no pudieron ser guardadas, debido a: #{errors.to_sentence.downcase}"
    end
    redirect_to especie_path(@especie)
  rescue Errno::ETIMEDOUT
    flash[:error] = t(:request_timed_out)
    redirect_to especie_path(@especie)
=begin
  rescue Koala::Facebook::APIError => e
    raise e unless e.message =~ /OAuthException/
    flash[:error] = t(:facebook_needs_the_owner_of_that_photo_to, :site_name_short => CONFIG.site_name_short)
    redirect_back_or_default(taxon_path(@taxon))
=end
  end

  def describe
    @describers = if CONFIG.taxon_describers
                    CONFIG.taxon_describers.map{|d| TaxonDescribers.get_describer(d)}.compact
                  elsif @especie.iconic_taxon_name == "Amphibia" && @especie.species_or_lower?
                    [TaxonDescribers::Wikipedia, TaxonDescribers::AmphibiaWeb, TaxonDescribers::Eol]
                  else
                    [TaxonDescribers::Wikipedia, TaxonDescribers::Eol]
                  end

    if @describer = TaxonDescribers.get_describer(params[:from])
      @description = @describer.equal?(TaxonDescribers::EolEs) ? @describer.describe(@especie, :language => 'es') : @describer.describe(@especie)
    else
      @describers.each do |d|
        @describer = d
        @description = begin
          d.equal?(TaxonDescribers::EolEs) ? d.describe(@especie, :language => 'es') : d.describe(@especie)
        rescue OpenURI::HTTPError, Timeout::Error => e
          nil
        end
        break unless @description.blank?
      end
    end
=begin
    if @describers.include?(TaxonDescribers::Wikipedia) && @especie.wikipedia_summary.blank?
      @taxon.wikipedia_summary(:refresh_if_blank => true)
    end
=end
    @describer_url = @describer.page_url(@especie)
    respond_to do |format|
      format.html { render :partial => 'description' }
    end
  end


  private

  def set_especie(arbol = false)
    begin
      @especie = Especie.find(params[:id])

      # Por si no viene del arbol, ya que no necesito encontrar el valido
      if !arbol
        if @especie.estatus == 1  # Si es un sinonimo lo redireccciona al valido
          estatus = @especie.especies_estatus

          if estatus.length == 1  # Nos aseguramos que solo haya un valido
            begin
              @especie = Especie.find(estatus.first.especie_id2)
              redirect_to especie_path(@especie)
            rescue
              render :_error and return
            end
          elsif estatus.length > 1  # Tienes muchos validos, tampoco deberia pasar
            render :_error and return
          else  # Es sinonimo pero no tiene un valido asociado >.>!
            if params[:action] == 'resultados'  # Por si viene de resultados, ya que sin esa condicon entrariamos a un loop
              redirect_to especie_path(@especie) and return
            end
          end
        else
          if params[:action] == 'resultados'  # Mando directo al valido, por si viene de resulados
            redirect_to especie_path(@especie) and return
          end
        end
      end
    rescue    #si no encontro el taxon
      render :_error and return
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

  def nodos_arbol
    if @despliega_o_contrae  # Si es para desplegar o contraer
      nodo = ''
      if I18n.locale.to_s == 'es-cientifico'
        @taxones = Especie.datos_basicos.
            caso_rango_valores('especies.id', @especie.child_ids.join(',')).order(:nombre_cientifico)
            #.each do |children|
          #nodo+= enlacesDelArbol(children, true)
        #end

      else # Solo las categorias taxonomicas obligatorias
        @taxones = Especie.none
        # Quito las categorias que no pertecene a la estructura del taxon (Division o Phylum)
        cat_obl = if @especie.ancestry_ascendente_directo.include?('1000001') || @especie.id == 1000001
                    CategoriaTaxonomica::CATEGORIAS_OBLIGATORIAS.map{|c| c if c != 'división'}.compact
                  else
                    CategoriaTaxonomica::CATEGORIAS_OBLIGATORIAS.map{|c| c if c != 'phylum'}.compact
                  end

        index_cat = cat_obl.index(@especie.categoria_taxonomica.nombre_categoria_taxonomica)
        return @taxones if index_cat.nil?  # Si no encontro la categoria
        return @taxones if index_cat == cat_obl.length - 1 # Si es la ultima categoria
        index_cat+= 1

        ancestry = @especie.is_root? ? @especie.id : "#{@especie.ancestry_ascendente_directo}/#{@especie.id}"

        @taxones = Especie.datos_basicos.where("ancestry_ascendente_directo LIKE '#{ancestry}%'").caso_status('2').
            caso_sensitivo('nombre_categoria_taxonomica',cat_obl[index_cat]).order(:nombre_cientifico)
                       #.each do |children|
          #nodo+= enlacesDelArbol(children, true)
        #end
      end

    else # Si es para cuando se despliega la pagina
      if @especie.nil?  # Si es el index
        arbolCompleto = ''
        @taxones = Especie.datos_basicos.where('nivel1=1 AND nivel2=0 AND nivel3=0 AND nivel4=0')
        @arbol_inicial = true  # Quiere decir que es el arbol solo con los 5 reinos
                       #.each do |t|
          #arbolCompleto << "<ul class=\"nodo_mayor\">" + enlacesDelArbol(t) + '</li></ul></ul>'
        #end
        # Pone los reinos en una lista separada cada uno
        #arbolCompleto

      else # Si es cualquier otro taxon
        tags = ''
        arbolCompleto = "<ul class=\"nodo_mayor\">"
        contadorNodos = 0

        if I18n.locale.to_s == 'es-cientifico'
          @taxones = Especie.datos_basicos.select('CONCAT(nivel1,nivel2,nivel3,nivel4) as nivel').
              caso_rango_valores('especies.id', @especie.path_ids.join(',')).order('nivel')
              #.each do |ancestro|
            #arbolCompleto << enlacesDelArbol(ancestro)
            #contadorNodos+= 1
          #end
        else  # Solo las categorias taxonomicas obligatorias
          @taxones = Especie.datos_basicos.select('CONCAT(nivel1,nivel2,nivel3,nivel4) as nivel').
              caso_rango_valores('especies.id', @especie.path_ids.join(',')).
              caso_rango_valores('nombre_categoria_taxonomica', CategoriaTaxonomica::CATEGORIAS_OBLIGATORIAS.map{|c| "'#{c}'"}.join(',')).
              order('nivel')
                         #.each do |ancestro|
            #arbolCompleto << enlacesDelArbol(ancestro)
            #contadorNodos+= 1
          #end
        end

        @arbol_inicial = false  # Quiere decir que es el arbol de algun taxon en particular

        #contadorNodos.times {tags << '</li></ul>'}
        #arbolCompleto + tags + '</ul>'
      end
    end
  end

  def genera_obj_d3
    @children_array = []

    taxones = Especie.select_basico.datos_basicos.caso_rango_valores('especies.id',@especie.path_ids.join(',')).order_por_categoria('DESC')

    taxones.each_with_index do |t, i|
      @i = i
      children_hash = asigna_hash_d3(t, arbol_inicial: true)

      # Acumula el resultado del json anterior una posicion antes de la actual
      @children_array << children_hash
    end

    # Regresa el ultimo que es el mas actual
    @children_array.last
  end

  def asigna_hash_d3(t, opts={})
    children_hash = {}
    categoria = t.categoria_taxonomica.nivel1

    radius_min_size = 5
    radius_size = radius_min_size
    children_hash[:radius_size] = radius_size

    # Se muestra el numero de especies o inferiores de genero hacia arriba
    if categoria < 6
      ancestry = t.is_root? ? "#{t.id}/%" : "#{t.ancestry_ascendente_directo}/#{t.id}/%"
      especies_o_inferiores = Especie.where("ancestry_ascendente_directo LIKE '#{ancestry}'").
          where(estatus: 2).where('nivel1=7').categoria_taxonomica_join.count

      children_hash[:especies_inferiores_conteo] = especies_o_inferiores

      # URL para ver las especies o inferiores
      url = "/busquedas/resultados?id_nom_cientifico=#{t.id}&busqueda=avanzada&por_pagina=100&nivel=>%3D&cat=7100"
      children_hash[:especies_inferiores_url] = url

      #  Radio de los nodos para un mejor manejo hacia D3
      if especies_o_inferiores > 0

        #  Radios varian de 60 a 40
        if especies_o_inferiores >= 10000
          size_per_radium_unit = (especies_o_inferiores-10000)/20
          radius_size = ((especies_o_inferiores-10000)/size_per_radium_unit) + 40

        elsif especies_o_inferiores >= 1000 && especies_o_inferiores <= 9999  # Radios varian de 40 a 30
          radius_per_range = ((especies_o_inferiores)*10)/9999
          radius_size = radius_per_range + 30

        elsif especies_o_inferiores >= 100 && especies_o_inferiores <= 999  # Radios varian de 30 a 20
          radius_per_range = ((especies_o_inferiores)*10)/999
          radius_size = radius_per_range + 20

        elsif especies_o_inferiores >= 10 && especies_o_inferiores <= 99  # Radios varian de 20 a 10

          radius_per_range = ((especies_o_inferiores)*10)/99
          radius_size = radius_per_range + 10

        elsif especies_o_inferiores >= 1 && especies_o_inferiores <= 9  # Radios varian de 10 a 5

          radius_per_range = ((especies_o_inferiores)*5)/9
          radius_size = radius_per_range + radius_min_size

        end  # End if especies_inferiores_conteo > 0

        children_hash[:radius_size] = radius_size
      end
    else
      children_hash[:especies_inferiores_conteo] = 0
    end

    children_hash[:especie_id] = t.id
    children_hash[:name] = t.nombre_cientifico
    children_hash[:nombre_categoria_taxonomica] = t.nombre_categoria_taxonomica

    if opts[:arbol_inicial]
      if @i+1 != 1  # Si es taxon mas bajo no tiene hijos
        children_hash[:children] = [@children_array[@i-1]]
      end
    end

    children_hash
  end

  def retrieve_photos
    #[retrieve_remote_photos, retrieve_local_photos].flatten.compact
    [retrieve_remote_photos].flatten.compact
  end

  def retrieve_remote_photos
    photo_classes = Photo.descendent_classes - [LocalPhoto]
    photos = []
    photo_classes.each do |photo_class|
      param = photo_class.to_s.underscore.pluralize
      next if params[param].blank?
      params[param].reject {|i| i.blank?}.uniq.each do |photo_id|
        if fp = photo_class.find_by_native_photo_id(photo_id)
          photos << fp
        else
          pp = photo_class.get_api_response(photo_id)
          photos << photo_class.new_from_api_response(pp, current_usuario.id) if pp
        end
      end
    end
    photos
  end

  def retrieve_local_photos
    return [] if params[:local_photos].blank?
    photos = []
    params[:local_photos].reject {|i| i.blank?}.uniq.each do |photo_id|
      if fp = LocalPhoto.find_by_native_photo_id(photo_id)
        photos << fp
      end
    end
    photos
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
end
