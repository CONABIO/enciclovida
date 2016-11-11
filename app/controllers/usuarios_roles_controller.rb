class UsuariosRolesController < ApplicationController
  before_action :set_usuario_rol, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_usuario!
  before_action do
    permiso = tiene_permiso?(2)  # Minimo administrador
    render 'shared/sin_permiso' unless permiso
    @no_render_busqueda_basica = true
  end

  # GET /usuarios_roles
  # GET /usuarios_roles.json
  def index
    @usuarios_roles = UsuarioRol.join_user_rol.order(:usuario_id, :id).load
  end

  # GET /usuarios_roles/1
  # GET /usuarios_roles/1.json
  def show
  end

  # GET /usuarios_roles/new
  def new
    #@usuarios = Usuarios.load
    #@roles = Roles.load
    @usuario_rol = UsuarioRol.new
  end

  # GET /usuarios_roles/1/edit
  def edit
  end

  # POST /usuarios_roles
  # POST /usuarios_roles.json
  def create
    @usuario_rol = UsuarioRol.new(usuario_rol_params)

    respond_to do |format|
      if @usuario_rol.save
        format.html { redirect_to @usuario_rol, notice: 'El Rol fue añadido al usuario exitosamente.' }
        format.json { render action: 'show', status: :created, location: @usuario_rol }
      else
        format.html { render action: 'new' }
        format.json { render json: @usuario_rol.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /usuarios_roles/1
  # PATCH/PUT /usuarios_roles/1.json
  def update
    respond_to do |format|
      if @usuario_rol.update(usuario_rol_params)
        format.html { redirect_to @usuario_rol, notice: 'El Rol del usuario se actualizo correctamente.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @usuario_rol.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /usuarios_roles/1
  # DELETE /usuarios_roles/1.json
  def destroy
    @usuario_rol.destroy
    respond_to do |format|
      format.html { redirect_to usuarios_roles_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_usuario_rol
      @usuario_rol = UsuarioRol.join_user_rol.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def usuario_rol_params
      params.require(:usuario_rol).permit(:usuario_id, :rol_id)
    end
end
