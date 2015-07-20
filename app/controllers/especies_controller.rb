class EspeciesController < ApplicationController

  skip_before_filter :set_locale, only: [:datos_principales, :kmz, :kmz_naturalista, :create, :update, :edit_photos]
  before_action :set_especie, only: [:show, :edit, :update, :destroy, :arbol, :edit_photos, :update_photos, :describe,
                                     :datos_principales, :kmz, :kmz_naturalista, :cat_tax_asociadas]
  before_action :authenticate_usuario!, :only => [:new, :create, :edit, :update, :destroy, :destruye_seleccionados]
  before_action :only => [:new, :create, :edit, :update, :destroy, :destruye_seleccionados] do
    permiso = tiene_permiso?(100)  # Minimo administrador
    render :_error unless permiso
  end

  layout false, :only => [:describe, :arbol, :datos_principales, :kmz, :kmz_naturalista, :edit_photos, :cat_tax_asociadas]

  # Pone en cache el webservice que carga por default
  caches_action :describe, :expires_in => 1.week, :cache_path => Proc.new { |c| "especies/#{c.params[:id]}/#{c.params[:from]}" }

  #c.session.blank? || c.session['warden.user.user.key'].blank?
  #}
  #cache_sweeper :taxon_sweeper, :only => [:update, :destroy, :update_photos]

  # GET /especies
  # GET /especies.json
  def index
    #@especies = Especie.limit(100)
    #respond_to do |format|
    #  format.html
      #format.xlsx {
      #  send_data @especies.to_xlsx.to_stream.read, :filename => 'especies.xlsx', :type => 'application/vnd.openxmlformates-officedocument.spreadsheetml.sheet'
      #}
    #end
  end

  # GET /especies/1
  # GET /especies/1.json
  def show
    # Esto es para mostrar primero las fotos de NaturaLista, despues las de CONABIO
    fotos_naturalista = @especie.photos.where("type != 'ConabioPhoto'")
    fotos_conabio = @especie.photos.where(type: 'ConabioPhoto')
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
               :template => 'especies/show.pdf.erb',
               :encoding => 'UTF-8',
               :wkhtmltopdf => CONFIG.wkhtmltopdf_path
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

  def resultados
    # Por si no coincidio nada
    @taxones = Especie.none
    # Despliega directo el taxon, si paso id
    if params[:id].present?
      set_especie
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
            @paginacion = paginacion(totales, pagina, params[:por_pagina] ||= Especie::POR_PAGINA_PREDETERMINADO)

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
            @paginacion = paginacion(@taxones.length, pagina, params[:por_pagina] ||= Especie::POR_PAGINA_PREDETERMINADO) if @taxones.any?
          end


          if !@taxones.empty? && params[:pagina].present? && params[:pagina].to_i > 1
            # Para desplegar solo una categoria de resultados, o el paginado con el scrolling
            render :partial => 'especies/_resultados'
          elsif @taxones.empty? && params[:pagina].present? && params[:pagina].to_i > 1
            # El scrolling acaba
            render text: ''
          elsif @taxones.empty?
            redirect_to :root, :notice => 'Tu búsqueda no dio ningun resultado.'
          end

          # Ojo si no entro a ningun condicional desplegara el render normal de resultados.

        when 'nombre_cientifico'
          estatus =  I18n.locale.to_s == 'es-cientifico' ?  (params[:estatus].join(',') if params[:estatus].present?) : '2'

          sql = "Especie.datos_basicos.
            caso_insensitivo('nombre_cientifico', \"#{params[:nombre_cientifico].limpia_sql}\").where(\"estatus IN (#{estatus ||= '2, 1'})\").
            order('nombre_cientifico ASC')"

          consulta = eval(sql).to_sql
          totales = eval(sql).count
          pagina = params[:pagina].present? ? params[:pagina].to_i : 1

          if totales > 0
            @taxones = consulta << " OFFSET #{(pagina-1)*params[:por_pagina].to_i} ROWS FETCH NEXT #{params[:por_pagina].to_i} ROWS ONLY"
            @taxones = Especie.find_by_sql(@taxones)
            @paginacion = paginacion(totales, pagina, params[:por_pagina] ||= Especie::POR_PAGINA_PREDETERMINADO)
          else

            if @taxones.empty?
              ids=FUZZY_NOM_CIEN.find(params[:nombre_cientifico], limit=CONFIG.limit_fuzzy)

              if ids.present?
                @taxones = Especie.none
                taxones=Especie.datos_basicos.
                    caso_rango_valores('especies.id', "#{ids.join(',')}").where("estatus IN (#{estatus ||= '2, 1'})").order('nombre_cientifico ASC')

                taxones.each do |taxon|
                  # Si la distancia entre palabras es menor a 3 que muestre la sugerencia
                  distancia = Levenshtein.distance(params[:nombre_cientifico].downcase, taxon.nombre_cientifico.limpiar.downcase)
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
            @paginacion = paginacion(@taxones.length, pagina, params[:por_pagina] ||= Especie::POR_PAGINA_PREDETERMINADO) if @taxones.any?
          end


          if !@taxones.empty? && params[:pagina].present? && params[:pagina].to_i > 1
            # Para desplegar solo una categoria de resultados, o el paginado con el scrolling
            render :partial => 'especies/_resultados'
          elsif @taxones.empty? && params[:pagina].present? && params[:pagina].to_i > 1
            # El scrolling acaba
            render text: ''
          elsif @taxones.empty?
            redirect_to :root, :notice => 'Tu búsqueda no dio ningun resultado.'
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
          if params[:prioritaria].present? && params[:prioritaria] == '1'
            condiciones << ".where('especies.prioritaria IS NOT NULL')"
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
          @por_categoria = Especie.por_categoria(busqueda, distinct) if params[:solo_categoria].blank? && conID.present?
          pagina = params[:pagina].present? ? params[:pagina].to_i : 1

          if distinct
            totales = eval(busqueda.gsub('datos_basicos','datos_count'))[0].totales

            if totales > 0
              @paginacion = paginacion(totales, pagina, params[:por_pagina] ||= Especie::POR_PAGINA_PREDETERMINADO)

              if params[:checklist]=="1" # Reviso si me pidieron una url que contien parametro checklist (Busqueda CON FILTROS)
                @taxones = Especie.por_arbol(busqueda)
                checklists
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
              @paginacion = paginacion(totales, pagina, params[:por_pagina] ||= Especie::POR_PAGINA_PREDETERMINADO)

              if params[:checklist]=="1" # Reviso si me pidieron una url que contien parametro checklist (Busqueda SIN FILTROS)
                @taxones = Especie.por_arbol(busqueda, true)
                checklists(true)
              end
              @taxones = Especie.find_by_sql(@taxones)

            end
          end

          # Para desplegar solo una categoria de resultados, o el paginado con el scrolling
          if params[:solo_categoria].present?
            if params[:pagina].present? && params[:pagina].to_i > 1 && !@taxones.empty?
              render :partial => 'especies/_resultados'
            elsif @taxones.empty?
              render text: ''
            else
              render :partial => 'especies/resultados'
            end
          elsif params[:pagina].present? && params[:pagina].to_i > 1 && !@taxones.empty?
              render :partial => 'especies/_resultados'
          elsif @taxones.empty? && params[:pagina].present? && params[:pagina].to_i > 1
            render text: ''
          elsif params[:checklist].present? && params[:checklist].to_i == 1
            respond_to do |format|
              format.html { render 'especies/checklists' }
              format.pdf do  #Para imprimir el listado en PDF
                ruta = Rails.root.join('public', 'pdfs').to_s
                fecha = Time.now.strftime("%Y%m%d%H%M%S")
                pdf = "#{ruta}/#{fecha}_#{rand(1000)}.pdf"
                FileUtils.mkpath(ruta, :mode => 0755) unless File.exists?(ruta)

                render :pdf => 'listado_de_especies',
                       :save_to_file => pdf,
                       #:save_only => true,
                       :template => 'especies/checklists.pdf.erb',
                       :encoding => 'UTF-8',
                       :wkhtmltopdf => CONFIG.wkhtmltopdf_path,
                       :orientation => 'Landscape'
              end
              format.xlsx do
                @columnas = @taxones.to_a.map(&:serializable_hash)[0].map{|k,v| k}
              end
            end
            #render 'especies/checklists'
          end

        else  # Default switch
          respond_to do |format|
            format.html { redirect_to :root, :notice => 'Búsqueda incorrecta por favor intentalo de nuevo.' }
          end
      end  # Fin switch
    end
  end

  def busca_por_lote
  end

  def checklists(sin_filtros=false) #Acción que genera los checklists de aceurdo a un set de resultados
    if sin_filtros
      #Sin no tengo filtros, dibujo el checklist tal y caul como lo recibo (render )
    else
      padres = {}
      #@taxones.map {|taxon| taxon.arbol.split('/').each {|p| @padres[p.to_i]=''}}
      @taxones.each do |taxon|
        taxon.arbol.split('/').each do |p|
          padres[p.to_i]=''
        end
      end
      @taxones = Especie.datos_arbol_sin_filtros.where("especies.id in (#{padres.keys.join(',')})").order('arbol')
    end
  end

  def resultados_por_lote
    return @match_taxa= 'Por lo menos debe haber un taxón o un archivo' unless params[:lote].present? || params[:batch].present?

    if params[:lote].present?
      @match_taxa = Hash.new
      params[:lote].split("\r\n").each do |linea|
        #e= Especie.where("nombre_cientifico ILIKE '#{linea}'")       #linea de postgres
        e= Especie.where("nombre_cientifico = '#{linea}'")       #linea de SQL Server
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
      format.html { redirect_to especies_index_path, :notice => "El taxón #{@especie.nombre_cientifico} fue elimanado correctamente" }
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

  # Las categoras asociadas de acuerdo al taxon que escogio
  def cat_tax_asociadas
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_especie
    begin
      @especie = Especie.find(params[:id])

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

  def tabs

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
