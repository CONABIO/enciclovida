class UsuariosController < ApplicationController
  skip_before_action :set_locale, only: [:create, :update, :destroy, :cambia_locale]
  skip_before_action :verify_authenticity_token, only: [:cambia_locale]
  before_action :authenticate_usuario!, :only => [:index, :show, :edit, :update, :destroy, :conabio]
  before_action :set_usuario, only: [:show, :edit, :update, :destroy]
  layout :false, :only => [:cambia_locale]

  before_action :only => [:index] do
    tiene_permiso?('Administrador') # Minimo administrador
  end
  before_action :only => [:destroy] do
    tiene_permiso?('Super usuario') # Solo ROOT tiene permiso de destruir MUAJAJAJA!
  end
  before_action :only => [:conabio] do
    tiene_permiso?('AdminComentarios', true) # Minimo administrador de comentarios de área
  end
  before_action do
    @no_render_busqueda_basica = true
  end

  # GET /usuarios
  # GET /usuarios.json
  def index
    @usuarios = Usuario.join_userRolEspeciesCategoriasContenido.load
  end

  def conabio
    @usuarios = Usuario.join_userRolEspeciesCategoriasContenido.where("usuarios.email like '%conabio%'").order('usuarios.nombre ASC, apellido asc').load
    render :action => 'index'
  end

  # GET /usuarios/1
  # GET /usuarios/1.json
  def show
  end

  # GET /usuarios/new
  def new
    @usuario = Usuario.new
  end

  # GET /usuarios/1/edit
  def edit
  end

  # POST /usuarios
  # POST /usuarios.json
  def create
    @usuario = Usuario.new(usuario_params)

    respond_to do |format|
      if @usuario.save
        format.html { redirect_to inicia_sesion_usuarios_url, notice: 'Tu cuenta fue creada exitosamente.' }
        format.json { render action: 'show', status: :created, location: @usuario }
      else
        format.html { render action: 'new' }
        format.json { render json: @usuario.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /usuarios/1
  # PATCH/PUT /usuarios/1.json
  def update
    respond_to do |format|
      if @usuario.update(usuario_params)
        format.html { redirect_to @usuario, notice: 'Tu cuenta ha sido actualizada exitosamente.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @usuario.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /usuarios/1
  # DELETE /usuarios/1.json
  def destroy
    @usuario.destroy
    respond_to do |format|
      format.html { redirect_to usuarios_url }
      format.json { head :no_content }
    end
  end

  def cambia_locale
    cookies[:vista] = {value: (cookies[:vista] == 'es-cientifico' ? I18n.default_locale : 'es-cientifico'), expires: 2.weeks.from_now}
    render json: {estatus: true}
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_usuario
    @usuario_completo = Usuario.join_userRolEspeciesCategoriasContenido.where("usuarios.id = #{params[:id]}")
    @usuario = @usuario_completo.first
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def usuario_params
    params.require(:usuario).permit(:usuario, :correo, :nombre, :apellido, :institucion,
                                    :contrasenia, :confirma_contrasenia)
  end

  def busqueda_avanzada

  end

end
