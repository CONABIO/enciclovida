class Admin::CatalogosController < Admin::AdminController

  before_action do
    @no_render_busqueda_basica = true
  end

  before_action :set_admin_catalogo, only: [:show, :edit, :update, :destroy]

  # GET /admin/catalogos
  # GET /admin/catalogos.json
  def index
    @admin_catalogos = Admin::Catalogo.usos
  end

  # GET /admin/catalogos/1
  # GET /admin/catalogos/1.json
  def show
  end

  # GET /admin/catalogos/new
  def new
    @form_params = { url: '/admin/catalogos', method: 'post' }
    @admin_catalogo = Admin::Catalogo.new
  end

  # GET /admin/catalogos/1/edit
  def edit
    @form_params = {}
    @admin_catalogos = Admin::Catalogo.includes(especies_catalogo: :especie).where(id: params[:id])
  end

  # POST /admin/catalogos
  # POST /admin/catalogos.json
  def create
    @admin_catalogo = Admin::Catalogo.new(admin_catalogo_params)

    respond_to do |format|
      if @admin_catalogo.save
        format.html { redirect_to @admin_catalogo, notice: 'Catalogo was successfully created.' }
        format.json { render action: 'show', status: :created, location: @admin_catalogo }
      else
        format.html { render action: 'new' }
        format.json { render json: @admin_catalogo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/catalogos/1
  # PATCH/PUT /admin/catalogos/1.json
  def update
    respond_to do |format|
      if @admin_catalogo.update(admin_catalogo_params)
        format.html { redirect_to @admin_catalogo, notice: 'Catalogo was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @admin_catalogo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/catalogos/1
  # DELETE /admin/catalogos/1.json
  def destroy
    @admin_catalogo.destroy
    respond_to do |format|
      format.html { redirect_to catalogos_url }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_admin_catalogo
    @admin_catalogo = Admin::Catalogo.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def admin_catalogo_params
    params.require(:admin_catalogo).permit(:descripcion, especies_catalogo_attributes: [:id, :especie_id, :_destroy])
  end

end
