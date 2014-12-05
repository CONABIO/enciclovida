class EspeciesController < ApplicationController

  skip_before_filter :set_locale, only: [:datos_principales, :arbol, :kml, :create, :update, :edit_photos, :filtros]
  before_action :set_especie, only: [:show, :edit, :update, :destroy, :arbol,
                                     :edit_photos, :update_photos, :describe, :datos_principales, :kml]
  before_action :authenticate_usuario!, :only => [:new, :create, :edit, :update, :destroy, :destruye_seleccionados, :description]
  layout false, :only => [:describe, :arbol, :datos_principales, :kml, :edit_photos, :filtros]

  # pone en cache el webservice que carga por default
  caches_action :describe, :expires_in => 1.week, :cache_path => Proc.new { |c| "especies/#{c.params[:id]}/#{c.params[:from]}" }

  #c.session.blank? || c.session['warden.user.user.key'].blank?
  #}
  #cache_sweeper :taxon_sweeper, :only => [:update, :destroy, :update_photos]

  # GET /especies
  # GET /especies.json
  def index
    respond_to do |format|
      format.html
      format.json { render json: EspecieDatatable.new(view_context) }
    end
  end

  # GET /especies/1
  # GET /especies/1.json
  def show
    @photos = @especie.photos
    #@photos = Rails.cache.fetch(@especie.photos_cache_key) do
    #  @especie.photos_with_backfill(:skip_external => true, :limit => 24)
    #end

    @desc.present? ? @ficha = @desc : @ficha = '<em>No existe ninguna ficha asociada con este tax&oacute;n</em>'
    @nombre_mapa = URI.encode("\"#{@especie.nombre_cientifico}\"")

    respond_to do |format|
      format.html
      format.json { render json: @especie.to_json }
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
          format.html { redirect_to :root, notice: 'Lo sentimos esa p&aacute;gina no existe'.html_safe }
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

  def resultados
    # Por si no coincidio nada
    @taxones = Especie.none

    # Despliega directo el taxon
    if params[:busqueda] == 'basica' || params[:id].present?
      set_especie
      respond_to do |format|
        format.html { redirect_to @especie }
      end
    else

      # Hace el query de l tipo de busqueda
      case params[:busqueda]

        when 'nombre_comun'
          sql="NombreComun.select(\"especies.id, nombre_comun, #{:nombre_cientifico}, #{:nombre_comun_principal}, #{:foto_principal}, #{:categoria_taxonomica_id}, #{:nombre_categoria_taxonomica}\").
              nom_com.caso_insensitivo('nombre_comun', \"#{params[:nombre_comun].gsub("'", "''")}\").where('especies.id IS NOT NULL').uniq.
              order('nombre_cientifico ASC')"

          longitud = eval("#{sql}.count")
          @paginacion = paginacion(longitud, params[:pagina] ||=1, params[:por_pagina] ||= Especie::POR_PAGINA_PREDETERMINADO)

          if longitud > 0
            @taxones = eval(sql).to_sql << " OFFSET #{params[:pagina].to_i*(params[:por_pagina].to_i-1)} ROWS FETCH NEXT #{params[:por_pagina].to_i} ROWS ONLY"
            @taxones = NombreComun.find_by_sql(@taxones)
          end

          if @taxones.empty?
            ids=FUZZY_NOM_COM.find(params[:nombre_comun], limit=CONFIG.limit_fuzzy)
            encontro_con_distancia = false

            ids.each do |id|
              @taxones=NombreComun.select('especies.*, nombre_categoria_taxonomica, nombre_comun').
                  nom_com.where("nombres_comunes.id=#{id}")

              if @taxones.first
                # Si la distancia entre palabras es 1 que muestre la sugerencia
                distancia = Levenshtein.distance(params[:nombre_comun].downcase, @taxones.first.nombre_comun.downcase)
                @coincidencias='¿Quiz&aacute;s quiso decir algunos de los siguientes taxones?'.html_safe

                if distancia != 1
                  next
                else
                  encontro_con_distancia = true
                  break
                end

              else
                # Si no hubo coincidencias con el fuzzy match
                next
              end
            end

            if !encontro_con_distancia
              redirect_to :root, :notice => 'Tu búsqueda no dio ningun resultado.'
            end
          end

        when 'nombre_cientifico'
          estatus = "#{params[:estatus_basica_cientifico_1]}," if params[:estatus_basica_cientifico_1].present?
          estatus+= "#{params[:estatus_basica_cientifico_2]}," if params[:estatus_basica_cientifico_2].present?
          estatus = /^\d,$/.match(estatus) ? estatus.tr(',', '') : nil        #por si eligio los dos status

          sql="Especie.select('especies.*, nombre_categoria_taxonomica').categoria_taxonomica_join.
            caso_insensitivo('nombre_cientifico', \"#{params[:nombre_cientifico].gsub("'", "''")}\").where(\"estatus IN (#{estatus ||= '2, 1'})\").
            order('nombre_cientifico ASC')"

          longitud = eval("#{sql}.count")
          @paginacion = paginacion(longitud, params[:pagina] ||=1, params[:por_pagina] ||= Especie::POR_PAGINA_PREDETERMINADO)

          if longitud > 0
            @taxones = eval("#{sql}.to_sql") << " OFFSET #{params[:pagina].to_i*(params[:por_pagina].to_i-1)} ROWS FETCH NEXT #{params[:por_pagina].to_i} ROWS ONLY"
            @taxones = Especie.find_by_sql(@taxones)
          end

          if @taxones.empty?
            ids=FUZZY_NOM_CIEN.find(params[:nombre_cientifico], limit=CONFIG.limit_fuzzy)
            encontro_con_distancia = false

            ids.each do |id|
              @taxones = Especie.select('especies.*, nombre_categoria_taxonomica').categoria_taxonomica_join.
                  where(:id => id)

              if @taxones.first
                # Si la distancia entre palabras es 1 que muestre la sugerencia
                distancia = Levenshtein.distance(params[:nombre_cientifico].downcase, @taxones.first.nombre_cientifico.downcase)
                @coincidencias='¿Quiz&aacute;s quiso decir algunos de los siguientes taxones?'.html_safe

                if distancia != 1
                  next
                else
                  encontro_con_distancia = true
                  break
                end

              else
                # Si no hubo coincidencias con el fuzzy match
                next
              end
            end

            if !encontro_con_distancia
              redirect_to :root, :notice => 'Tu búsqueda no dio ningun resultado.'
            end
          end

        when 'avanzada'
          #Es necesario hacer un index con estos campos para aumentar la velocidad
          busqueda = "Especie.select('especies.id, #{:nombre_cientifico}, #{:nombre_comun_principal}, #{:foto_principal}, #{:categoria_taxonomica_id}, #{:nombre_categoria_taxonomica}')"
          joins = condiciones = tipoDistribuciones = conID = nombre_cientifico = ''
          arbol = []
          distinct = false

          params.each do |key, value|  #itera sobre todos los campos

            if key == 'id_nom_cientifico' && value.present?
              conID = value.to_i
            elsif conID.blank? && key == 'id_nom_comun' && value.present?
              conID = value.to_i
            end

            if key == 'nombre_cientifico' && value.present? && conID.blank?
              nombre_cientifico+= value.gsub("'", "''")
            end

            if key == 'nombre_comun' && value.present? && conID.blank?
              joins+= '.nombres_comunes_join'
              condiciones+= ".caso_insensitivo('nombres_comunes.nombre_comun', \"#{value.gsub("'", "''")}\")"
            end

            if key.include?('tipo_distribucion_') && value.present?
              tipoDistribuciones+="'#{value}',"
              joins+= '.'+tipoDeAtributo('tipos_distribuciones')
              distinct = true
            end

            estatus+= "#{value}," if key.include?('estatus_avanzada_') && value.present?
          end

          estatus = /^\d,$/.match(estatus) ? estatus.tr(',', '') : nil
          joins+= '.categoria_taxonomica_join'
          condiciones+= ".caso_status(#{estatus})" if estatus.present?
          condiciones+= '.'+tipoDeBusqueda(5, 'tipos_distribuciones.descripcion', "#{tipoDistribuciones[0..-2]}") if tipoDistribuciones.present?

          if params[:categoria].present? ? params[:categoria].join('').present? : false
            if conID.blank?                 #join a la(s) categorias taxonomicas (params)
              cat_tax = "\"'#{params[:categoria].map{ |val| val.blank? ? nil : val }.compact.join("','")}'\""
              condiciones+= ".caso_rango_valores('nombre_categoria_taxonomica', #{cat_tax})"
              condiciones+= ".caso_insensitivo('nombre_cientifico', '#{nombre_cientifico}')" if conID.blank? && nombre_cientifico.present?
            else            #joins a las categorias con los descendientes
              taxon = Especie.find(conID)
              arbol << taxon.ancestor_ids << taxon.descendant_ids << conID       #el arbol completo
              cat_tax = "\"'#{params[:categoria].map{ |val| val.blank? ? nil : val }.compact.join("','")}'\""
              arbolIDS = "\"'#{arbol.compact.flatten.uniq.join("','")}'\""
              condiciones+= ".caso_rango_valores('especies.id', #{arbolIDS})"
              condiciones+= ".caso_rango_valores('nombre_categoria_taxonomica', #{cat_tax})"
            end
          else       # busquedas directas
            condiciones+= conID.present? ? ".caso_sensitivo('especies.id', '#{conID}')" :
                ".caso_insensitivo('nombre_cientifico', '#{nombre_cientifico}')" if nombre_cientifico.present?
          end

          #parte de la distribucion (lugares)
          if params[:distribucion_nivel_1].present?
            if params[:distribucion_nivel_2].present? || params[:distribucion_nivel_3].present?
              joins+= '.especies_regiones_join.region_join'
              region = Region.find(params[:distribucion_nivel_3].present? ? params[:distribucion_nivel_3] : params[:distribucion_nivel_2])
              condiciones+= '.' + tipoDeBusqueda(3, 'regiones.nombre_region', region.nombre_region)
            else
              joins+= '.especies_regiones_join.region_join.tipo_region_join'
              tipo_region = TipoRegion.find(params[:distribucion_nivel_1])
              condiciones+= '.' + tipoDeBusqueda(3, 'tipos_regiosnes.descripcion', tipo_region)
            end
            distinct = true
          end

          #Parte del edo. de conservacion
          if params[:edo_cons].present?
            joins+= '.catalogos_join'
            condiciones+= ".caso_rango_valores('catalogos.descripcion', \"'#{params[:edo_cons].join("','")}'\")"
            distinct = true
          end

          busqueda+= joins.split('.').join('.') + condiciones      #pone los joins unicos

          if distinct
            longitud = eval(busqueda).order('nombre_cientifico ASC').distinct.count
            @paginacion = paginacion(longitud, params[:pagina] ||=1, params[:por_pagina] ||= Especie::POR_PAGINA_PREDETERMINADO)

            if longitud > 0
              @taxones = eval(busqueda).order('nombre_cientifico ASC').distinct.to_sql << " OFFSET #{params[:pagina].to_i*(params[:por_pagina].to_i-1)} ROWS FETCH NEXT #{params[:por_pagina].to_i} ROWS ONLY"
              @taxones = Especie.find_by_sql(@taxones)
            end
          else
            longitud = eval(busqueda).order('nombre_cientifico ASC').count
            @paginacion = paginacion(longitud, params[:pagina] ||=1, params[:por_pagina] ||= Especie::POR_PAGINA_PREDETERMINADO)

            if longitud > 0
              @taxones = eval(busqueda).order('nombre_cientifico ASC').to_sql << " OFFSET #{params[:pagina].to_i*(params[:por_pagina].to_i-1)} ROWS FETCH NEXT #{params[:por_pagina].to_i} ROWS ONLY"
              @taxones = Especie.find_by_sql(@taxones)
            end
          end
        else
          respond_to do |format|
            format.html { redirect_to :root, :notice => 'Búsqueda incorrecta por favor intentalo de nuevo2.' }
          end
      end
    end
  end

  def busca_por_lote
  end

  def resultados_por_lote
    return @match_taxa= 'Por lo menos debe haber un taxón o un archivo' unless params[:lote].present? || params[:batch].present?

    if params[:lote].present?
      @match_taxa = Hash.new
      params[:lote].split("\r\n").each do |linea|
        e= Especie.where("nombre_cientifico ILIKE '#{linea}'")       #linea de postgres
        if e.first
          @match_taxa[linea] = e
        else
          ids = FUZZY_NOM_CIEN.find(linea, 3)
          coincidencias = ids.present? ? Especie.where("especies.id IN (#{ids.join(',')})").order('nombre_cientifico ASC') : nil
          @match_taxa[linea] = coincidencias.length > 0 ? coincidencias : 'Sin coincidencia'
        end
      end
    elsif params[:batch].present?
      validaBatch(params[:batch])

    end
    #@match_taxa = @match_taxa ? errores.join(' ') : 'Los datos fueron procesados correctamente'
  end

  def datos_principales
  end

# DELETE /especies/1
# DELETE /especies/1.json
  def destroy
    @especie.destroy
    bitacora=Bitacora.new(:descripcion => "Eliminó al taxón #{@especie.nombre_cientifico} (#{@especie.id})", :usuario_id => current_usuario.id)
    bitacora.save
    respond_to do |format|
      format.html { redirect_to especies_url, :notice => "El taxón #{@especie.nombre_cientifico} fue elimanado correctamente" }
      format.json { head :no_content }
    end
  end

  #Despliega o contrae o muestra el arbol de un inicio
  def arbol
    @accion = to_boolean(params[:accion]) if params[:accion].present?
  end

  def dame_listas
    respond_to do |format|
      format.html { render :json => dameListas(@listas) }
    end
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
    redirect_to especy_path(@especie)
  rescue Errno::ETIMEDOUT
    flash[:error] = t(:request_timed_out)
    redirect_to especy_path(@especie)
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

  def kml
    if params[:kml].present? && to_boolean(params[:kml])
      proveedor = @especie.proveedor
      if proveedor
        if proveedor.snib_kml.present?
          send_data proveedor.snib_kml, :filename => "#{@especie.nombre_cientifico}.kml"
        end
      else
        render :text => 'No existe KML para este tax&oacute;n'.html_safe
      end
    else
# Cache del KMZ
      if Rails.cache.exist?("snib_#{@especie.id}")
        redirect_to "/assets/#{@especie.id}/registros.kmz"
      else
        Rails.cache.fetch(@especie.snib_cache_key, expires_in: 5.minutes) do
          proveedor = @especie.proveedor
          if proveedor
            proveedor.kml
            if proveedor.snib_kml.present?
              proveedor.save
              if proveedor.kmz
                redirect_to "/assets/#{@especie.id}/registros.kmz"
              else
                render :text => 'No existe KML para este tax&oacute;n'.html_safe
              end
            else
              render :text => 'No existe KML para este tax&oacute;n'.html_safe
            end
          else
            render :text => 'No existe KML para este tax&oacute;n'.html_safe
          end
        end
      end
    end
  end

  # Decide cual filtro cargar y regresa el html y si es nuevo o no
  def filtros
    filtro = Filtro.consulta(usuario_signed_in? ? current_usuario : nil, request.session_options[:id])
    if filtro.present? && filtro.html.present?
      render :text => filtro.html.html_safe
    else
      # Por default hace render de filtros
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_especie
    begin
      @especie = Especie.find(params[:id])
      @accion=params[:controller]
    rescue
      render :_error
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
          photos << photo_class.new_from_api_response(pp) if pp
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

  def tipoDeAtributo(tipo)
    case tipo
      when 'nombre_comun'
        relacion='nombres_comunes_join'
      when 'tipos_distribuciones'
        relacion='especies_regiones_join.tipo_distribucion_join'   #fue necesario separar ese join para ver si ya estaba repetido
      when 'catalogos.descripcion'
        relacion='catalogos_join'
      else
        relacion=''
    end
    return relacion
  end

  def validaBatch(batch)
    errores = []
    formatos_permitidos = %w(text/csv text/plain)
    path = Rails.root.join('tmp', 'batchs')
    file = path.join(Time.now.strftime("%Y_%m_%d_%H-%M-%S") + '_' + batch.original_filename)
    Dir.mkdir(path, 0700) if !File.exists?(path)

    if !formatos_permitidos.include? batch.content_type
      errores << 'Lo sentimos, el formato ' + batch.content_type + ' no esta permitido'
      return @match_taxa = errores.join(' ')
    end

    File.open(file, 'wb') do |file|
      file.write(batch.read)
    end

    File.open(file, 'r') do |f|
      if !(1..1000).cover? f.readlines.size         #no mas de 1000 taxones por consulta para no forzar la base
        errores << "Lo sentimos, no se permiten #{f.readlines.size} lineas."
        File.delete file
        return @match_taxa = errores.join(' ')
      end
    end

    @match_taxa = Hash.new
    lineas=File.open(file).read

    lineas.each_line do |linea|
      l = linea.strip
      e = Especie.where(:nombre_cientifico => l)
      if e.first
        @match_taxa[l] = e
      else
        ids = FUZZY_NOM_CIEN.find(l, 3)
        coincidencias = ids.present? ? Especie.where("especies.id IN (#{ids.join(',')})").order('nombre_cientifico ASC') : nil
        @match_taxa[l] = coincidencias.present? ? coincidencias : 'Sin coincidencia'
      end
    end
  end
end
