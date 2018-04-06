#!/bin/env ruby
# encoding: utf-8
class EspeciesController < ApplicationController

  skip_before_action :set_locale, only: [:create, :update, :edit_photos, :comentarios, :fotos_referencia,
                                         :fotos_naturalista, :fotos_bdi, :nombres_comunes_naturalista,
                                         :nombres_comunes_todos, :observaciones_naturalista, :observacion_naturalista,
                                         :ejemplares_snib, :ejemplar_snib, :cambia_id_naturalista]
  before_action :set_especie, only: [:show, :edit, :update, :destroy, :edit_photos, :update_photos, :describe,
                                     :observaciones_naturalista, :observacion_naturalista, :cat_tax_asociadas,
                                     :descripcion_catalogos, :comentarios, :fotos_bdi,
                                     :fotos_referencia, :fotos_naturalista, :nombres_comunes_naturalista,
                                     :nombres_comunes_todos, :ejemplares_snib, :ejemplar_snib, :cambia_id_naturalista]
  before_action :only => [:arbol, :arbol_nodo, :hojas_arbol_nodo, :hojas_arbol_identado] do
    set_especie(true)
  end

  before_action :authenticate_usuario!, :only => [:new, :create, :edit, :update, :destroy, :destruye_seleccionados, :cambia_id_naturalista]

  before_action :only => [:new, :create, :edit, :update, :destroy, :destruye_seleccionados, :cambia_id_naturalista] do
    tiene_permiso?('Administrador')  # Minimo administrador
  end

  before_action :servicios, only: [:show]

  layout false, :only => [:describe, :observaciones_naturalista, :edit_photos, :descripcion_catalogos,
                          :arbol, :arbol_nodo, :hojas_arbol_nodo, :hojas_arbol_identado, :comentarios,
                          :fotos_referencia, :fotos_bdi, :media_cornell, :fotos_naturalista, :nombres_comunes_naturalista,
                          :nombres_comunes_todos, :ejemplares_snib, :ejemplar_snib, :observacion_naturalista, :cambia_id_naturalista]

  # Pone en cache el webservice que carga por default
  caches_action :describe, :expires_in => eval(CONFIG.cache.fichas), :cache_path => Proc.new { |c| "especies/#{c.params[:id]}/#{c.params[:from]}" } if Rails.env.production?

  # GET /especies
  # GET /especies.json
  def index
    redirect_to root_path
  end

  # GET /especies/1
  # GET /especies/1.json
  def show

    respond_to do |format|
      format.html do

        if adicional = @especie.adicional
          @nombre_comun_principal = adicional.nombre_comun_principal
        end

        @especie_o_inferior = @especie.especie_o_inferior?

        # Para saber si es espcie y tiene un ID asociado a NaturaLista
        if proveedor = @especie.proveedor
          @con_naturalista = proveedor.naturalista_id if proveedor.naturalista_id.present?

          if @especie_o_inferior
            geodatos = proveedor.geodatos
            @geo = geodatos if geodatos[:cuales].any?
          end
        end

        # Para los comentarios
        @cuantos = @especie.comentarios.where('comentarios.estatus IN (2,3) AND ancestry IS NULL').count
      end

      format.json do
        @especie.e_geodata = []

        if @especie.species_or_lower?
          if proveedor = @especie.proveedor
            geodatos = proveedor.geodatos
            @especie.e_geodata = geodatos if geodatos[:cuales].any?
          end
        end

        @especie.e_nombre_comun_principal = nil
        @especie.e_foto_principal = nil
        @especie.e_nombres_comunes = nil

        if a = @especie.adicional
          @especie.e_nombre_comun_principal = a.nombre_comun_principal
          @especie.e_foto_principal = a.foto_principal
          @especie.e_nombres_comunes = a.nombres_comunes
        end

        @especie.e_categoria_taxonomica = @especie.categoria_taxonomica
        @especie.e_tipo_distribucion = @especie.tipos_distribuciones
        @especie.e_estado_conservacion = @especie.estados_conservacion
        @especie.e_bibliografia = @especie.bibliografias
        @especie.e_fotos = ["#{CONFIG.site_url}especies/#{@especie.id}/fotos-bdi.json", "#{CONFIG.site_url}especies/#{@especie.id}/fotos-naturalista.json"]  # TODO: poner las fotos de referencia, actaulmente es un metodo post

        render json: @especie.to_json(methods: [:e_geodata, :e_nombre_comun_principal, :e_foto_principal,
                                                :e_nombres_comunes, :e_categoria_taxonomica, :e_tipo_distribucion,
                                                :e_estado_conservacion, :e_bibliografia, :e_fotos])
      end

      format.pdf do
        @photos = @especie.fotos_bdi[:fotos]

        # wicked_pdf no admite request en ajax, lo llamamos directo antes del view
        @describers = if CONFIG.taxon_describers
                        CONFIG.taxon_describers.map{|d| TaxonDescribers.get_describer(d)}.compact
                      elsif @especie.iconic_taxon_name == "Amphibia" && @especie.species_or_lower?
                        [TaxonDescribers::Wikipedia, TaxonDescribers::AmphibiaWeb, TaxonDescribers::Eol]
                      else
                        [TaxonDescribers::Wikipedia, TaxonDescribers::Eol]
                      end

        if params[:from].present? && CONFIG.taxon_describers.include?(params[:from].downcase)
          # Especifico una descripcion y esta dentro de los permitidos
          d = TaxonDescribers.get_describer(params[:from])
          @description = d.equal?(TaxonDescribers::EolEs) ? d.describe(@especie, :language => 'es') : d.describe(@especie)

        else  # No especifico una descripcion y mandara a llamar el que encuentre
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

  # Despliega el arbol, viene de la pestaña de la ficha
  def arbol
    if I18n.locale.to_s == 'es-cientifico'
      obj_arbol_identado
      render :partial => 'arbol_identado'
    else
      render :partial => 'arbol_nodo'
    end
  end

  # JSON que se ocupara para desplegar los datos en D3
  def arbol_nodo
    @children_array = []

    taxones = Especie.select_basico(['ancestry_ascendente_directo', 'conteo', 'categorias_taxonomicas.nivel1']).datos_basicos.
        categoria_conteo_join.where("categoria='7_00' OR categoria IS NULL").caso_rango_valores('especies.id',@especie.path_ids.join(',')).
        where("nombre_categoria_taxonomica IN ('#{CategoriaTaxonomica::CATEGORIAS_OBLIGATORIAS.join("','")}')").
        where(estatus: 2).order_por_categoria('DESC')

    taxones.each_with_index do |t, i|
      @i = i
      children_hash = hash_arbol_nodo(t, arbol_inicial: true)

      # Acumula el resultado del json anterior una posicion antes de la actual
      @children_array << children_hash
    end

    # Regresa el ultimo que es el mas actual
    json_d3 = @children_array.last

    render :json => json_d3.to_json
  end

  # JSON que despliega solo un nodo con sus hijos, para pegarlos en json ya construido con d3
  def hojas_arbol_nodo
    children_array = []

    nivel_categoria = @especie.categoria_taxonomica.nivel1
    ancestry = @especie.is_root? ? @especie.id : "#{@especie.ancestry_ascendente_directo}/%#{@especie.id}%"

    taxones = Especie.select_basico(['ancestry_ascendente_directo', 'conteo', 'categorias_taxonomicas.nivel1']).datos_basicos.
        categoria_conteo_join.where("categoria='7_00' OR categoria IS NULL").where("ancestry_ascendente_directo LIKE '#{ancestry}'").
        where("nombre_categoria_taxonomica IN ('#{CategoriaTaxonomica::CATEGORIAS_OBLIGATORIAS.join("','")}')").
        where("nivel1=#{nivel_categoria + 1} AND nivel3=0 AND nivel4=0").  # Con estas condiciones de niveles aseguro que es una categoria principal
    where(estatus: 2)

    taxones.each do |t|
      children_hash = hash_arbol_nodo(t)

      # Acumula el resultado del json anterior una posicion antes de la actual
      children_array << children_hash
    end

    render :json => children_array.to_json
  end

  def hojas_arbol_identado
    hijos = @especie.child_ids

    # Quita el propio ID del taxon para que no se repita cuando se despliegan en el arbol
    taxon_orig = Especie.find(params[:origin_id])
    taxon_orig_ancestros = taxon_orig.path_ids
    hijos.delete_if {|h| taxon_orig_ancestros.include?(h) }

    if hijos.any?
      @taxones = Especie.datos_basicos.
          caso_rango_valores('especies.id', hijos.join(',')).order(:nombre_cientifico)
    else
      @taxones = Especie.none
    end

    @despliega_o_contrae = true
    render :partial => 'arbol_identado'
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
      f_obj.attribution_txt = f['attribution']
      @fotos << f_obj
    end

    @foto_default = @fotos.first
  end

  # Servicio de lib/bdi_service.rb
  def fotos_bdi
    @pagina = params['pagina']

    if @pagina.present?
      bdi = @especie.fotos_bdi({pagina: @pagina.to_i})
    else
      bdi = @especie.fotos_bdi
    end

    if bdi[:estatus] == 'OK'
      @fotos = bdi[:fotos]

      respond_to do |format|
        format.json {render json: bdi}
        format.html do

          # El conteo de las paginas
          totales = 0
          por_pagina = 25

          # Por ser la primera saco el conteo de paginas
          if @pagina.blank?
            # Saca el conteo de las fotos de bdi
            if bdi[:ultima].present?
              totales+= por_pagina*(bdi[:ultima]-1)
              fbu = @especie.fotos_bdi({pagina: bdi[:ultima]})
              totales+= fbu[:fotos].count if fbu[:estatus] == 'OK'
              @paginas = totales%por_pagina == 0 ? totales/por_pagina : (totales/por_pagina) +1
            end
          end  # End pagina blank
        end  # End format html
      end  # End respond

    else  # End estatus OK
      render :_error and return
    end
  end

  #servicio Macaulay Library (eBird)
  def media_cornell
    type = params['type']
    page = params['page']
    taxonNC = Especie.find(params['id']).nombre_cientifico
    mc = MacaulayService.new
    @array = mc.dameMedia_nc(taxonNC, type, page)

    render :locals => {type: type, page: page}
  end

  def fotos_naturalista
    fotos = if p = @especie.proveedor
              p.fotos_naturalista
            else
              {estatus: 'error', msg: 'No hay resultados por nombre científico en naturalista'}
            end

    render json: fotos
  end

  def nombres_comunes_naturalista
    nombres_comunes = if p = @especie.proveedor
                        p.nombres_comunes_naturalista
                      else
                        {estatus: 'error', msg: 'No hay resultados por nombre científico en naturalista'}
                      end

    render json: nombres_comunes
  end

  def nombres_comunes_todos
    @nombres_comunes = @especie.nombres_comunes_todos
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

  # Viene de la pestaña de la ficha
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

  # Viene de la pestaña de la ficha
  def descripcion_catalogos
  end

  # Devuelve las observaciones de naturalista en diferentes formatos
  def observaciones_naturalista
    if p = @especie.proveedor

      respond_to do |format|
        format.json do
          resp = p.observaciones_naturalista('.json')

          headers['Access-Control-Allow-Origin'] = '*'
          headers['Access-Control-Allow-Methods'] = 'GET'
          headers['Access-Control-Request-Method'] = '*'
          headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'

          if resp[:estatus] == 'OK'
            resp[:resultados] = JSON.parse(File.read(resp[:ruta]))
            resp.delete(:ruta)
            render json: resp
          else
            resp.delete(:ruta)
            render json: resp.to_json
          end
        end

        format.kml do
          resp = p.observaciones_naturalista('.kml')

          if resp[:estatus] == 'OK'
            archivo = File.read(resp[:ruta])
            send_data archivo, :filename => resp[:ruta].split('/').last
          else
            resp.delete(:ruta)
            render json: resp.to_json
          end
        end

        format.kmz do
          resp = p.observaciones_naturalista('.kmz')

          if resp[:estatus] == 'OK'
            archivo = File.read(resp[:ruta])
            send_data archivo, :filename => resp[:ruta].split('/').last
          else
            resp.delete(:ruta)
            render json: resp.to_json
          end
        end
      end  # End respond_to
    else
      render :_error and return
    end
  end

  # Obtiene la informacion de una observacion del archivo .json, esto es para no mostrar toda la informacion cuando se construye el mapa
  def observacion_naturalista
    if p = @especie.proveedor
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'GET'
      headers['Access-Control-Request-Method'] = '*'
      headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'

      resp = p.observacion_naturalista(params['observacion_id'])
      resp.delete(:ruta) if resp[:ruta].present?
      render json: resp.to_json
    else
      render json: {estatus: 'error', msg: 'No existe naturalista_id'}.to_json
    end
  end

  # Devuelve los ejemplares del SNIB en diferentes formatos
  def ejemplares_snib
    if p = @especie.proveedor

      respond_to do |format|
        format.json do
          resp = p.ejemplares_snib('.json')

          headers['Access-Control-Allow-Origin'] = '*'
          headers['Access-Control-Allow-Methods'] = 'GET'
          headers['Access-Control-Request-Method'] = '*'
          headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'

          if resp[:estatus] == 'OK'
            resp[:resultados] = JSON.parse(File.read(resp[:ruta]))
            resp.delete(:ruta)
            render json: resp
          else
            resp.delete(:ruta)
            render json: resp.to_json
          end
        end

        format.kml do
          resp = p.ejemplares_snib('.kml')

          if resp[:estatus] == 'OK'
            archivo = File.read(resp[:ruta])
            send_data archivo, :filename => resp[:ruta].split('/').last
          else
            resp.delete(:ruta)
            render json: resp.to_json
          end
        end

        format.kmz do
          resp = p.ejemplares_snib('.kmz')

          if resp[:estatus] == 'OK'
            archivo = File.read(resp[:ruta])
            send_data archivo, :filename => resp[:ruta].split('/').last
          else
            resp.delete(:ruta)
            render json: resp.to_json
          end
        end
      end  # End respond_to
    else
      render :_error and return
    end
  end

  # Obtiene la informacion del ejemplar del archivo .json, esto es para no mostrar toda la informacion cuando se construye el mapa
  def ejemplar_snib
    if p = @especie.proveedor
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'GET'
      headers['Access-Control-Request-Method'] = '*'
      headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'

      resp = p.ejemplar_snib(params['ejemplar_id'])
      resp.delete(:ruta) if resp[:ruta].present?
      render json: resp.to_json
    else
      render json: {estatus: 'error', msg: 'No existe en el SNIB'}.to_json
    end
  end

  # Muestra los comentarios relacionados a la especie, viene de la pestaña de la ficha
  def comentarios
    @comentarios = Comentario.datos_basicos.where(especie_id: @especie).where('comentarios.estatus IN (2,3) AND ancestry IS NULL').order('comentarios.created_at DESC')

    @comentarios.each do |c|
      c.cuantos = c.descendants.count
      c.completa_info((c.usuario_id if c.is_root?))
    end
  end

  def cambia_id_naturalista
    new_id = params[:new_url].gsub(/\D/, '').to_i
    if p = @especie.proveedor
      # existe proveedor'
      p.naturalista_id = new_id
    else
      # NO existe proveedor
      p = @especie.proveedor.new({naturalista_id: new_id})
    end

    if p.changed? && p.save
      # 'cambio, y salvó
      @especie.borra_cache('observaciones_naturalista') if @especie.existe_cache?('observaciones_naturalista')
      redirect_to especie_path(@especie), notice: 'El cambio fue exitoso, puede que tarde un poco en lo que se actualiza el cache'
    else
      # no cambio y no salvó
      redirect_to especie_path(@especie), notice: 'No se logro el cambio, el id era el mismo, hubo un error en la url proporcionada, contactar programadores con pantallazo.'
    end
  end

  private

  def set_especie(arbol = false)
    #begin
      @especie = Especie.find(params[:id])
      suma_visita  # Servicio para sumar las visitas por especie, pase el parametro ya que no conserva la variable
      cuantas_especies_inferiores(estadistica_id: 2)  # Servicio para poner el numero totales de especies del taxon
      cuantas_especies_inferiores(estadistica_id: 3)  # Servicio para poner el numero totales de especies o inferiores del taxon

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
    #rescue    #si no encontro el taxon
    #  render :_error and return
    #end
  end

  # REVISADO: Suma una visita a la estadisticas
  def suma_visita
    # Me aseguro que viene de la ficha, para poner el contador y que es solo del formato html
    if params[:action] == 'show' && request.format.html?
      if Rails.env.production?
        @especie.delay(queue: 'estadisticas').suma_visita
      else
        @especie.suma_visita
      end
    end  # if show
  end

  # REVISADO: Cuenta en numero de especies o el numero de especies mas las inferiores de una taxon, depende del argumento
  def cuantas_especies_inferiores(opc = {})
    if params[:action] == 'show'
      if Rails.env.production?
        if !@especie.existe_cache?("estadisticas_cuantas_especies_inferiores_#{opc[:estadistica_id]}")
          @especie.delay(queue: 'estadisticas').cuantas_especies_inferiores(opc)
        end
      else
        @especie.cuantas_especies_inferiores(opc)
      end
    end  # if show
  end

  # Actualiza las observaciones, los nombres comunes y las fotos
  def servicios
    # Para guardar los cambios en redis y las observacion
    if Rails.env.production?
      @especie.delay(queue: 'redis').guarda_redis

      if !@especie.existe_cache?('observaciones_naturalista')
        @especie.delay(queue: 'observaciones_naturalista').guarda_observaciones_naturalista
      end

      if !@especie.existe_cache?('ejemplares_snib')
        @especie.delay(queue: 'ejemplares_snib').guarda_ejemplares_snib
      end

    else
      @especie.guarda_redis
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

  def obj_arbol_identado
    @taxones = Especie.datos_basicos.select('CONCAT(nivel1,nivel2,nivel3,nivel4) as nivel').
        caso_rango_valores('especies.id', @especie.path_ids.join(',')).order('nivel')
  end

  def hash_arbol_nodo(t, opts={})
    children_hash = {}
    categoria = t.nivel1

    if categoria == 7
      children_hash[:color] = '#748c17';
    elsif categoria == 1
      children_hash[:color] = '#c27113'
    else
      children_hash[:color] = '#C6DBEF'
    end

    radius_min_size = 8
    radius_size = radius_min_size
    children_hash[:radius_size] = radius_size

    especies_o_inferiores = t.conteo.present? ? t.conteo : 0
    children_hash[:especies_inferiores_conteo] = especies_o_inferiores

    # Decide si es phylum o division (solo reino animalia)
    nivel_especie = if t.root_id == 1000001
                      children_hash[:es_phylum] = '1'
                      '7100'
                    else
                      children_hash[:es_phylum] = '0'
                      '7000'
                    end

    # URL para ver las especies o inferiores
    url = "/busquedas/resultados?id=#{t.id}&busqueda=avanzada&por_pagina=50&nivel=%3D&cat=#{nivel_especie}&estatus[]=2"
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

      elsif especies_o_inferiores >= 10 && especies_o_inferiores <= 99  # Radios varian de 20 a 13

        radius_per_range = ((especies_o_inferiores)*7)/99
        radius_size = radius_per_range + 13

      elsif especies_o_inferiores >= 1 && especies_o_inferiores <= 9  # Radios varian de 13 a 8

        radius_per_range = ((especies_o_inferiores)*5)/9
        radius_size = radius_per_range + radius_min_size

      end  # End if especies_inferiores_conteo > 0

      children_hash[:radius_size] = radius_size
    end

    children_hash[:especie_id] = t.id
    children_hash[:nombre_cientifico] = t.nombre_cientifico
    children_hash[:nombre_comun] = t.nombre_comun_principal.try(:capitalize)

    # Pone la abreviacion de la categoria taxonomica
    cat = I18n.transliterate(t.nombre_categoria_taxonomica).downcase
    abreviacion_categoria = CategoriaTaxonomica::ABREVIACIONES[cat.to_sym].present? ? CategoriaTaxonomica::ABREVIACIONES[cat.to_sym] : ''
    children_hash[:abreviacion_categoria] = abreviacion_categoria

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
