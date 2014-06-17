class EspeciesController < ApplicationController
  include EspeciesHelper
  before_action :set_especie, only: [:show, :edit, :update, :destroy, :buscaDescendientes, :muestraTaxonomia]
  autocomplete :especie, :nombre, :column_name => 'nombre_cientifico', :full => true, :display_value => :personalizaBusqueda,
               :extra_data => [:id, :nombre_cientifico, :categoria_taxonomica_id], :limit => 10
  before_action :tienePermiso?, :only => [:new, :create, :edit, :update, :destroy, :destruye_seleccionados]
  before_action :cualesListas, :only => [:resultados, :dame_listas]
  layout false, :only => :dame_listas

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

    #@desc = TaxonDescribers::Conabio.describe(@especie)
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
    @vista=params[:busqueda_oculto]
    estatus = ''

    case params[:busqueda_oculto]
      when 'basica_comun'
        @taxones=eval("Especie.select('especies.*, nombre_comun, nombre_categoria_taxonomica').caso_categoria_taxonomica.caso_nombre_comun.
          #{tipoDeBusqueda(params[:condicion_nombre_comun], 'nombre_comun', params[:nombre_comun])}").order('nombre_comun ASC').paginate(:page => params[:page], :per_page => params[:per_page] || Especie.per_page)
        if @taxones.empty?
          ids=FUZZY_NOM_COM.find(params[:nombre_comun], limit=CONFIG.limit_fuzzy)
          if @taxones=ids.count > 0
            @taxones=Especie.select('especies.*, nombre_comun, nombre_categoria_taxonomica').caso_categoria_taxonomica.caso_nombre_comun.where("nombres_comunes.id IN (#{ids.join(',')})").order('nombre_comun ASC').uniq.paginate(:page => params[:page], :per_page => params[:per_page] || Especie.per_page)
            @coincidencias='Quiz&aacute;s quiso decir algunos de los siguientes taxones:'.html_safe
          end
        end
      when 'basica_cientifico'
        estatus+= "#{params[:estatus_basica_cientifico_1]}," if params[:estatus_basica_cientifico_1].present?
        estatus+= "#{params[:estatus_basica_cientifico_2]}," if params[:estatus_basica_cientifico_2].present?
        estatus = /^\d,$/.match(estatus) ? estatus.tr(',', '') : nil
        @taxones=eval("Especie.select('especies.*, nombre_categoria_taxonomica').caso_categoria_taxonomica.
          #{tipoDeBusqueda(params[:condicion_nombre_cientifico], 'nombre_cientifico', params[:nombre_cientifico])}#{".caso_estatus(#{estatus})" if estatus.present?}").order('nombre_cientifico ASC').uniq.paginate(:page => params[:page], :per_page => params[:per_page] || Especie.per_page)
        if @taxones.empty?
          ids=FUZZY_NOM_CIEN.find(params[:nombre_cientifico], limit=CONFIG.limit_fuzzy)
          if @taxones=ids.count > 0
            @taxones=Especie.select('especies.*, nombre_categoria_taxonomica').caso_categoria_taxonomica.where("especies.id IN (#{ids.join(',')})").order('nombre_cientifico ASC').uniq.paginate(:page => params[:page], :per_page => params[:per_page] || Especie.per_page)
            @coincidencias='Quiz&aacute;s quiso decir algunos de los siguientes taxones:'.html_safe
          end
        end
      when 'avanzada'
        busqueda = "Especie.select('especies.*, categorias_taxonomicas.nombre_categoria_taxonomica')"
        joins = condiciones = tipoDistribuciones = ''
        @conNombreComun = @conRegion = @conEstadoConservacion = false
        conIDCientifico = arbol = []

        params.each do |key, value|  #saca los taxones o subtaxones, depende si autocompleto
          if key.include?('bAtributo_')
            numero=key.split('_').last
            if params['hAtributo_' + numero].present? && (params[:categoria_taxonomica].present? ? params[:categoria_taxonomica].join('').present? : false)
              conIDCientifico << params['hAtributo_' + numero].to_i if value == 'nombre_cientifico'
            elsif params['vAtributo_' + numero].present?
            joins+= '.' + tipoDeAtributo(value) if tipoDeAtributo(value).present?
            condiciones+= '.' + tipoDeBusqueda(params['cAtributo_' + numero], value, params['vAtributo_' + numero]) if params['vAtributo_' + numero].present?
            end
          end

          if key.include?('tipo_distribucion_')
            tipoDistribuciones+="#{value},"
            joins+= '.'+tipoDeAtributo('tipos_distribuciones')
          end

          estatus+= "#{value}," if key == 'estatus_avanzada_1'
          estatus+= "#{value}," if key == 'estatus_avanzada_2'
        end

        estatus = /^\d,$/.match(estatus) ? estatus.tr(',', '') : nil
        joins+= '.caso_categoria_taxonomica'
        condiciones+= '.'+tipoDeBusqueda(5, 'tipos_distribuciones.id', tipoDistribuciones[0..-2]) if tipoDistribuciones.present?
        condiciones+= ".caso_estatus(#{estatus})" if estatus.present?

        if (params[:categoria_taxonomica].present? ? params[:categoria_taxonomica].join('').present? : false) && conIDCientifico.blank?  #join a la(s) categorias taxonomicas
          cat_tax = "\"'#{params[:categoria_taxonomica].map{ |val| val.blank? ? nil : val }.compact.join("','")}'\""
          condiciones+= ".caso_rango_valores('nombre_categoria_taxonomica', #{cat_tax})"
        elsif (params[:categoria_taxonomica].present? ? params[:categoria_taxonomica].join('').present? : false) && conIDCientifico.present? #joins a las categorias con los descendientes
          taxon = Especie.find(conIDCientifico.first)
          arbol << taxon.ancestor_ids << taxon.descendant_ids << conIDCientifico.first.to_i
          cat_tax = "\"'#{params[:categoria_taxonomica].map{ |val| val.blank? ? nil : val }.compact.join("','")}'\""
          arbolIDS = "\"'#{arbol.compact.flatten.join("','")}'\""
          condiciones+= ".caso_rango_valores('especies.id', #{arbolIDS})"
          condiciones+= ".caso_rango_valores('nombre_categoria_taxonomica', #{cat_tax})"
        end

        #parte de la distribucion
        if params[:distribucion_nivel_1].present?
          joins+= '.caso_region'
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
          format.html { redirect_to :root, :notice => 'Búsqueda incorrecta por favor intentalo de nuevo.' }
        end
    end
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
        relacion='caso_nombre_comun'
      when 'tipos_distribuciones'
        relacion='caso_tipo_distribucion'
      when 'catalogos.descripcion'
        relacion='caso_especies_catalogos'
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
end
