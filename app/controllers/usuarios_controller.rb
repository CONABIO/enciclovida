class UsuariosController < ApplicationController
  skip_before_filter :set_locale, only: [:create, :update, :destroy, :guarda_filtro, :limpiar, :cambia_locale]
  before_action :authenticate_usuario!, :only => [:index, :show, :edit, :update, :destroy]
  before_action :set_usuario, only: [:show, :edit, :update, :destroy]
  layout :false, :only => [:guarda_filtro, :cambia_locale, :limpiar]

  # GET /usuarios
  # GET /usuarios.json
  def index
    @usuarios = Usuario.all
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

  def guarda_filtro
    Filtro.guarda(request.session_options[:id], usuario_signed_in? ? current_usuario : nil, params[:html])
    render :text => 'ok'   #Para no dejar la salida con error
  end

  def limpiar
    Filtro.destruye(request.session_options[:id], usuario_signed_in? ? current_usuario : nil)
    render :text => true
  end

  def cambia_locale       #decide en donde gaurdar el locale
    return if params[:locale].blank? || !I18n.available_locales.map{ |loc| loc.to_s }.include?(params[:locale])

    if usuario_signed_in?
      current_usuario.locale = params[:locale]
      current_usuario.save if current_usuario.changed?
    else
      filtro = Filtro.where(:sesion => request.session_options[:id]).first
      filtro = Filtro.new unless filtro

      filtro.sesion = request.session_options[:id]
      filtro.locale = params[:locale]
      filtro.html = '' unless filtro.html.present?

      if filtro.new_record?
        filtro.save
      else
        filtro.save if filtro.changed?
      end
    end

    render :text => 'ok'
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_usuario
    @usuario = Usuario.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def usuario_params
    params.require(:usuario).permit(:usuario, :correo, :nombre, :apellido, :institucion,
                                    :grado_academico, :contrasenia, :confirma_contrasenia)
  end
end
