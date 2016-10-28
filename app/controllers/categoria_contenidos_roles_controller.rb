class CategoriaContenidosRolesController < ApplicationController
  before_action :set_categoria_contenido_rol, only: [:show, :edit, :update, :destroy]

  # GET /categoria_contenidos_roles
  # GET /categoria_contenidos_roles.json
  def index
    @categoria_contenidos_roles = CategoriaContenidoRol.all
  end

  # GET /categoria_contenidos_roles/1
  # GET /categoria_contenidos_roles/1.json
  def show
  end

  # GET /categoria_contenidos_roles/new
  def new
    @categoria_contenido_rol = CategoriaContenidoRol.new
  end

  # GET /categoria_contenidos_roles/1/edit
  def edit
  end

  # POST /categoria_contenidos_roles
  # POST /categoria_contenidos_roles.json
  def create
    @categoria_contenido_rol = CategoriaContenidoRol.new(categoria_contenido_rol_params)

    respond_to do |format|
      if @categoria_contenido_rol.save
        format.html { redirect_to @categoria_contenido_rol, notice: 'Categoria contenido rol was successfully created.' }
        format.json { render action: 'show', status: :created, location: @categoria_contenido_rol }
      else
        format.html { render action: 'new' }
        format.json { render json: @categoria_contenido_rol.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categoria_contenidos_roles/1
  # PATCH/PUT /categoria_contenidos_roles/1.json
  def update
    respond_to do |format|
      if @categoria_contenido_rol.update(categoria_contenido_rol_params)
        format.html { redirect_to @categoria_contenido_rol, notice: 'Categoria contenido rol was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @categoria_contenido_rol.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categoria_contenidos_roles/1
  # DELETE /categoria_contenidos_roles/1.json
  def destroy
    @categoria_contenido_rol.destroy
    respond_to do |format|
      format.html { redirect_to categoria_contenidos_roles_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_categoria_contenido_rol
      @categoria_contenido_rol = CategoriaContenidoRol.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def categoria_contenido_rol_params
      params.require(:categoria_contenido_rol).permit(:categoria_contenido_id, :rol_id)
    end
end
