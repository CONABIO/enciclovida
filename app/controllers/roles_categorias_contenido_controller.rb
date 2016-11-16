class RolesCategoriasContenidoController < ApplicationController
  before_action :set_rol_categorias_contenido, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_usuario!
  before_action { tiene_permiso?(2) } # Minimo administrador
  before_action do
    Rails.application.reload_routes!
    @no_render_busqueda_basica = true
  end

  # GET /roles_categorias_contenido
  # GET /roles_categorias_contenido.json
  def index
    @roles_categorias_contenido = RolCategoriasContenido.join_roles_categorias_contenidos.order(:rol_id).load
  end

  # GET /roles_categorias_contenido/1
  # GET /roles_categorias_contenido/1.json
  def show
  end

  # GET /roles_categorias_contenido/new
  def new
    @rol_categorias_contenido = RolCategoriasContenido.new
  end

  # GET /roles_categorias_contenido/1/edit
  def edit
  end

  # POST /roles_categorias_contenido
  # POST /roles_categorias_contenido.json
  def create
    @rol_categorias_contenido = RolCategoriasContenido.new(rol_categorias_contenido_params)

    respond_to do |format|
      if @rol_categorias_contenido.save
        format.html { redirect_to @rol_categorias_contenido, notice: 'Rol - CategoriasContenido se creo satisfactoriamente.' }
        format.json { render action: 'show', status: :created, location: @rol_categorias_contenido }
      else
        format.html { render action: 'new' }
        format.json { render json: @rol_categorias_contenido.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /roles_categorias_contenido/1
  # PATCH/PUT /roles_categorias_contenido/1.json
  def update
    respond_to do |format|
      if @rol_categorias_contenido.update(rol_categorias_contenido_params)
        format.html { redirect_to @rol_categorias_contenido, notice: 'Rol - CategoriasContenido se actualizó satisfactoriamente.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @rol_categorias_contenido.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /roles_categorias_contenido/1
  # DELETE /roles_categorias_contenido/1.json
  def destroy
    @rol_categorias_contenido.destroy
    respond_to do |format|
      format.html { redirect_to roles_categorias_contenido_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rol_categorias_contenido
      @rol_categorias_contenido = RolCategoriasContenido.join_roles_categorias_contenidos.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rol_categorias_contenido_params
      params.require(:rol_categorias_contenido).permit(:categoria_contenido_id, :rol_id)
    end
end
