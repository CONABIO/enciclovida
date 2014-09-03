class EspeciesController < ApplicationController
  include EspeciesHelper
  before_action :set_especie, only: [:show, :edit, :update, :destroy, :buscaDescendientes, :muestraTaxonomia, :edit_photos, :update_photos, :describe]
  autocomplete :especie, :nombre, :column_name => 'nombre_cientifico', :full => true, :display_value => :personalizaBusqueda,
               :extra_data => [:id, :nombre_cientifico, :categoria_taxonomica_id], :limit => 10
  before_action :tienePermiso?, :only => [:new, :create, :edit, :update, :destroy, :destruye_seleccionados]
  before_action :cualesListas, :only => [:resultados, :dame_listas]
  layout false, :only => :dame_listas

  #caches_action :describe, :expires_in => 1.day, :cache_path => {:locale => I18n.locale}#, :if => Proc.new {|c|
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
    @photos = Rails.cache.fetch(@especie.photos_cache_key) do
      @especie.photos_with_backfill(:skip_external => true, :limit => 24)
    end

    @desc.present? ? @ficha = @desc : @ficha = '<em>No existe ninguna ficha asociada con este tax&oacute;n</em>'
    @nombre_mapa = URI.encode("\"#{@especie.nombre_cientifico}\"")
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
    @especie.ancestry_acendente_obligatorio="#{ascendete.ancestry_acendente_obligatorio}/#{ascendete.id}"

    respond_to do |format|
      if @especie.save && params[:commit].eql?('Crear')
        descripcion="Creó un nuevo taxón(#{@especie.id}): #{@especie.categoria_taxonomica.nombre_categoria_taxonomica} ✓ #{@especie.nombre_cientifico}"
        bitacora=Bitacora.new(:descripcion => descripcion, :usuario_id => dameUsuario)
        bitacora.save
        guardaRelaciones(EspecieCatalogo)
        guardaRelaciones(EspecieRegion)
        format.html { redirect_to @especie, notice: "El taxón #{@especie.nombre_cientifico} fue creado exitosamente." }
        format.json { render action: 'show', status: :created, location: @especie }
      elsif @especie.save && params[:commit].eql?('Crear y seguir editando')
        descripcion="Creó un nuevo taxón: #{@especie.categoria_taxonomica.nombre_categoria_taxonomica} ✓ #{@especie.nombre_cientifico}"
        bitacora=Bitacora.new(:descripcion => descripcion, :usuario_id => dameUsuario)
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
        bitacora=Bitacora.new(:descripcion => descripcion, :usuario_id => dameUsuario)
        bitacora.save
        format.html { redirect_to @especie, notice: "El taxón #{@especie.nombre_cientifico} fue modificado exitosamente." }
        format.json { head :no_content }
      elsif @especie.update(argumentosRelaciones) && params[:commit].eql?('Guardar y seguir editando')
        descripcion="Actualizó el taxón #{@especie.nombre_cientifico} (#{@especie.id})"
        bitacora=Bitacora.new(:descripcion => descripcion, :usuario_id => dameUsuario)
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
    @busqueda=params[:busqueda]
    estatus = ''

    # Despliega directo el taxon
    if params[:busqueda] == 'basica' || params[:id].present?
      set_especie
      respond_to do |format|
        format.html { redirect_to @especie }
      end
    end

    case params[:busqueda]

      when 'nombre_comun'
        @taxones=NombreComun.select('especies.*, nombre_comun, nombre_categoria_taxonomica').
            nom_com.caso_insensitivo('nombre_comun', params[:nombre_comun]).
            order('nombre_cientifico ASC').paginate(:page => params[:page], :per_page => params[:per_page] || Especie.per_page)

        if @taxones.empty?
          ids=FUZZY_NOM_COM.find(params[:nombre_comun], limit=CONFIG.limit_fuzzy)
          if ids.count > 0
            @taxones=NombreComun.select('especies.*, nombre_comun, nombre_categoria_taxonomica').
                nom_com.where("nombres_comunes.id IN (#{ids.join(',')})").order('nombre_comun ASC').
                paginate(:page => params[:page], :per_page => params[:per_page] || Especie.per_page)
            @coincidencias='Quiz&aacute;s quiso decir algunos de los siguientes taxones:'.html_safe
          end
        end

      when 'nombre_cientifico'
        estatus = "#{params[:estatus_basica_cientifico_1]}," if params[:estatus_basica_cientifico_1].present?
        estatus+= "#{params[:estatus_basica_cientifico_2]}," if params[:estatus_basica_cientifico_2].present?
        estatus = /^\d,$/.match(estatus) ? estatus.tr(',', '') : nil        #por si eligio los dos status

        @taxones=Especie.select('especies.*, nombre_categoria_taxonomica').categoria_taxonomica_join.
            caso_insensitivo('nombre_cientifico', params[:nombre_cientifico]).where("estatus IN (#{estatus ||= '2, 1'})").order('nombre_cientifico ASC').
            paginate(:page => params[:page], :per_page => params[:per_page] || Especie.per_page)

        if @taxones.empty?
          ids=FUZZY_NOM_CIEN.find(params[:nombre_cientifico], limit=CONFIG.limit_fuzzy)
          if ids.count > 0

            @taxones=Especie.select('especies.*, nombre_categoria_taxonomica').categoria_taxonomica_join.
                where("especies.id IN (#{ids.join(',')})").order('nombre_cientifico ASC').
                paginate(:page => params[:page], :per_page => params[:per_page] || Especie.per_page)
            @coincidencias='Quiz&aacute;s quiso decir algunos de los siguientes taxones:'.html_safe
          end
        end

      when 'avanzada'
        busqueda = "Especie.select('especies.*, categorias_taxonomicas.nombre_categoria_taxonomica')"
        joins = condiciones = tipoDistribuciones = conID = nombre_cientifico = ''
        arbol = []

        params.each do |key, value|  #itera sobre todos los campos
=begin
          if key.include?('bAtributo_')
            numero=key.split('_').last  #el numero de atributo a consultar
            # Para ver si quiere ver todos los taxones descendentes de cierto taxon
            if params['hAtributo_' + numero].present? && (params[:categoria_taxonomica].present? ? params[:categoria_taxonomica].join('').present? : false)
              conIDCientifico << params['hAtributo_' + numero].to_i if value == 'nombre_cientifico'
            elsif params['vAtributo_' + numero].present?
              joins+= '.' + tipoDeAtributo(value) if tipoDeAtributo(value).present?
              condiciones+= '.' + tipoDeBusqueda(params['cAtributo_' + numero], value, params['vAtributo_' + numero]) if params['vAtributo_' + numero].present?
            end
          end
=end
          conID = value.to_i if key == 'id_nom_cientifico' && value.present?

          if key == 'nombre_cientifico' && value.present?
            nombre_cientifico+= ".caso_insensitivo('nombre_cientifico', '#{value}')"
          end

          if key == 'nombre_comun' && value.present?
            joins+= '.nombres_comunes_join'
            condiciones+= ".caso_insensitivo('nombres_comunes.nombre_comun', '#{value}')"
          end

          if key.include?('tipo_distribucion_') && value.present?
            tipoDistribuciones+="#{value},"
            joins+= '.'+tipoDeAtributo('tipos_distribuciones')
          end

          estatus+= "#{value}," if key.include?('estatus_avanzada_') && value.present?
        end

        estatus = /^\d,$/.match(estatus) ? estatus.tr(',', '') : nil
        joins+= '.categoria_taxonomica_join'
        condiciones+= ".caso_insensitivo('nombre_cientifico', '#{nombre_cientifico}')" if conID.blank? && nombre_cientifico.present?
        condiciones+= '.'+tipoDeBusqueda(5, 'tipos_distribuciones.id', tipoDistribuciones[0..-2]) if tipoDistribuciones.present?
        condiciones+= ".caso_status(#{estatus})" if estatus.present?

        if (params[:categoria].present? ? params[:categoria].join('').present? : false) && conID.blank?  #join a la(s) categorias taxonomicas (params)
          cat_tax = "\"'#{params[:categoria].map{ |val| val.blank? ? nil : val }.compact.join("','")}'\""
          condiciones+= ".caso_rango_valores('nombre_categoria_taxonomica', #{cat_tax})"
        elsif (params[:categoria].present? ? params[:categoria].join('').present? : false) && conID.present? #joins a las categorias con los descendientes
          taxon = Especie.find(conID)
          arbol << taxon.ancestor_ids << taxon.descendant_ids << conID       #el arbol completo
          cat_tax = "\"'#{params[:categoria].map{ |val| val.blank? ? nil : val }.compact.join("','")}'\""
          arbolIDS = "\"'#{arbol.compact.flatten.join("','")}'\""
          condiciones+= ".caso_rango_valores('especies.id', #{arbolIDS})"
          condiciones+= ".caso_rango_valores('nombre_categoria_taxonomica', #{cat_tax})"
        end

        #parte de la distribucion
        if params[:distribucion_nivel_1].present?
          joins+= '.especies_regiones_join.region_join'
          if params[:distribucion_nivel_2].present? || params[:distribucion_nivel_3].present?
            condiciones+= '.' + tipoDeBusqueda(3, 'regiones.id', params[:distribucion_nivel_3].present? ? params[:distribucion_nivel_3] : params[:distribucion_nivel_2])
          else
            condiciones+= '.' + tipoDeBusqueda(3, 'tipo_region_id', params[:distribucion_nivel_1])
          end
        end

        busqueda+= joins.split('.').uniq.join('.') + condiciones      #pone los joins unicos
        @taxones = eval(busqueda).order('nombre_cientifico ASC').uniq.paginate(:page => params[:page], :per_page => params[:per_page] || Especie.per_page)
      #@taxones=Especie.none
      #@resultado2= busqueda
      #@resultado=params
      else
        respond_to do |format|
          format.html { redirect_to :root, :notice => 'Búsqueda incorrecta por favor intentalo de nuevo2.' }
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

# DELETE /especies/1
# DELETE /especies/1.json
  def destroy
    @especie.destroy
    bitacora=Bitacora.new(:descripcion => "Eliminó al taxón #{@especie.nombre_cientifico} (#{@especie.id})", :usuario_id => dameUsuario)
    bitacora.save
    respond_to do |format|
      format.html { redirect_to especies_url, :notice => "El taxón #{@especie.nombre_cientifico} fue elimanado correctamente" }
      format.json { head :no_content }
    end
  end

  def aniade_taxones
    if params[:listas].present?
      incluyoAlgo ||=false
      params[:listas].split(',').each do |lista|
        listaDatos=Lista.find(lista)
        params.each do |key, value|
          if key.include?('box_especie_')
            begin
              listaDatos.cadena_especies.present? ? listaDatos.cadena_especies+=",#{value}" : listaDatos.cadena_especies=value
              incluyoAlgo=true
            rescue
              Rails.logger.info "***ERROR***Lista id: [#{lista}] ya no existe mas"
            end
          end
        end
        listaDatos.save
      end
      notice=incluyoAlgo ? 'Taxones incluidos correctamente.' : 'No seleccionaste ningún taxón.'
    else
      notice='Debes seleccionar por lo menos una lista para poder incluir los taxones.'
    end

    respond_to do |format|
      format.html { redirect_to :back, :notice => notice }
    end
  end

  def buscaDescendientes
    if taxon=params[:id]
      nodo ||='<ul>'
      @especie.child_ids.each do |childrenID|
        children=Especie.find(childrenID)
        nodo+=enlacesDelArbol(children, true)
      end
      respond_to do |format|
        format.html do
          render :json => nodo+='</ul>'
        end
      end
    end
  end

  def muestraTaxonomia
    if params[:id].present?
      taxon=params[:id]
      arbolCompleto ||="<ul class=\"nodo_mayor\">"
      if @especie.ancestry_acendente_obligatorio.present?
        contadorNodos ||=0;
        @especie.ancestry_acendente_obligatorio.split('/').each do |a|
          ancestro=Especie.find(a)
          if !ancestro.nil?
            arbolCompleto+=enlacesDelArbol(ancestro)
            contadorNodos+=1
          end
        end
        arbolCompleto+=enlacesDelArbol(@especie)
        respond_to do |format|
          format.html do
            render :json => arbolCompleto+='</li></ul>'*(contadorNodos+1)+'</ul>'
          end
        end
      end
    end
  end

  def dame_listas
    respond_to do |format|
      format.html { render :json => dameListas(@listas) }
    end
  end

  def edit_photos
    @photos = @especie.taxon_photos.sort_by{|tp| tp.id}.map{|tp| tp.photo}
    render :layout => false
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
          d.describe(@especie)
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
            bitacora=Bitacora.new(:descripcion => descripcion, :usuario_id => dameUsuario)
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
              bitacora=Bitacora.new(:descripcion => descripcion, :usuario_id => dameUsuario)
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
        "caso_rango_valores('#{columna}', '#{valor}')"
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

  def cualesListas
    usuario=dameUsuario
    if usuario.present?
      @listas=Lista.where(:usuario_id => usuario).order('nombre_lista ASC').limit(10)
      @listas=0 if @listas.empty?
    end
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
