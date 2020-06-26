class Admin::EspeciesCatalogosController < Admin::AdminController

  before_action :set_admin_especie_catalogo, only: [:show, :edit, :update, :destroy]

  before_action do
    @no_render_busqueda_basica = true
  end

  # GET /admin/especies_catalogos
  # GET /admin/especies_catalogos.json
  def index
    @admin_especies_catalogos = Admin::EspecieCatalogo.all
  end

  # GET /admin/especies_catalogos/1
  # GET /admin/especies_catalogos/1.json
  def show
  end

  # GET /admin/especies_catalogos/new
  def new
    @form_params = { url: '/admin/especies_catalogos', method: 'post' }
    if params.present? && params[:admin_especie_catalogo].present?
      @admin_especie_catalogo = Admin::EspecieCatalogo.new(admin_especie_catalogo_params)

      especie_id = params[:admin_especie_catalogo][:especie_id]
      if especie_id.present?
        @admin_especie_catalogo.nombre_cientifico = Especie.find(especie_id).nombre_cientifico
      end

    else
      @admin_especie_catalogo = Admin::EspecieCatalogo.new
    end
  end

  # GET /admin/especies_catalogos/1/edit
  def edit
    @admin_especie_catalogo.nombre_cientifico = Especie.find(@admin_especie_catalogo.especie_id).nombre_cientifico
    @form_params = {}
  end

  # POST /admin/especies_catalogos
  # POST /admin/especies_catalogos.json
  def create
    @admin_especie_catalogo = Admin::EspecieCatalogo.new(admin_especie_catalogo_params)

    respond_to do |format|

      @admin_especie_catalogo.usuario = current_usuario.email
      if @admin_especie_catalogo.save
        format.html do
          case params[:commit]
            when 'Guardar'   
              redirect_to admin_catalogos_path, notice: 'La asociación fue creada correctamente' 
            when 'Guardar y crear otra'
              redirect_to new_admin_especie_catalogo_path, notice: 'La asociación fue creada correctamente' 
            when 'Guardar y seguir editando'
              redirect_to edit_admin_especie_catalogo_path(@admin_especie_catalogo), notice: 'La asociación fue creada correctamente' 
          end
        end

        format.json { render :show, status: :created, location: @admin_especie_catalogo }
      else
        format.html do 
          @form_params = {}
          render :new
        end
        format.json { render json: @admin_especie_catalogo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/especies_catalogos/1
  # PATCH/PUT /admin/especies_catalogos/1.json
  def update
    respond_to do |format|

      @admin_especie_catalogo.usuario = current_usuario.email
      if @admin_especie_catalogo.update(admin_especie_catalogo_params)
        format.html do
          case params[:commit]
            when 'Actualizar'   
              redirect_to admin_catalogos_path, notice: 'La asociación fue actualizada correctamente' 
            when 'Actualizar y crear otra'
              redirect_to new_admin_especie_catalogo_path, notice: 'La asociación fue actualizada correctamente' 
            when 'Actualizar y seguir editando'
              redirect_to edit_admin_especie_catalogo_path(@admin_especie_catalogo), notice: 'La asociación fue actualizada correctamente' 
          end
        end

        format.json { render :show, status: :ok, location: @admin_especie_catalogo }
      else
        format.html do
          @form_params = {}
          render :edit
        end
        format.json { render json: @admin_especie_catalogo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/especies_catalogos/1
  # DELETE /admin/especies_catalogos/1.json
  def destroy
    @admin_especie_catalogo.destroy
    respond_to do |format|
      format.html { redirect_to admin_catalogos_path, notice: 'La asociación fue eliminada correctamente' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_especie_catalogo
      @admin_especie_catalogo = Admin::EspecieCatalogo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_especie_catalogo_params
      p = params.require(:admin_especie_catalogo).permit(:especie_id, :catalogo_id, :observaciones, :nombre_cientifico, bibliografias_attributes: [:id, :especie_id, :catalogo_id, :bibliografia_id, :observaciones, :biblio, :_destroy], regiones_attributes: [:id, :especie_id, :catalogo_id, :region_id, :observaciones, :reg, :_destroy, bibliografias_attributes: [:id, :especie_id, :catalogo_id, :region_id, :bibliografia_id, :observaciones, :biblio, :_destroy]])

      separa_multiples_llaves_foraneas(p)
    end

    # Para que pueda seguir guardando con el comportamiento de cocoon con multiples llaves foráneas
  def separa_multiples_llaves_foraneas(p)
    usuario = current_usuario.email

    if p["bibliografias_attributes"].present?
      p["bibliografias_attributes"].each do |kbiblio, biblio|
        next unless biblio.present?
        next unless biblio["id"].present?
        next unless biblio["catalogo_id"].present?
        next unless biblio["especie_id"].present?
        next unless biblio["bibliografia_id"].present?
        biblio["id"] = [biblio["catalogo_id"], biblio["especie_id"], biblio["bibliografia_id"]]
        biblio["usuario"] = usuario
      end
    end

    # Iterando cada elemento especie_catalogo_region
    if p["regiones_attributes"].present?
      p["regiones_attributes"].each do |kregion, region|
        next unless region.present?
        next unless region["id"].present?
        next unless region["catalogo_id"].present?
        next unless region["especie_id"].present?
        next unless region["region_id"].present?
        region["id"] = [region["catalogo_id"], region["especie_id"], region["region_id"]]
        region["usuario"] = usuario

        # Iterando cada elemento especie_catalogo_region_bibliografia
        if region["bibliografias_attributes"].present?
          region["bibliografias_attributes"].each do |kbiblio, biblio|
            next unless biblio.present?
            next unless biblio["id"].present?
            next unless biblio["catalogo_id"].present?
            next unless biblio["especie_id"].present?
            next unless biblio["region_id"].present?
            next unless biblio["bibliografia_id"].present?
            biblio["id"] = [biblio["catalogo_id"], biblio["especie_id"], biblio["region_id"], biblio["bibliografia_id"]]
            biblio["usuario"] = usuario
          end
        end
      end
    end
    p
  end

end
