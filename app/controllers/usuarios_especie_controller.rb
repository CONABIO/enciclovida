class UsuariosEspecieController < ApplicationController
  before_action :set_usuario_especie, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_usuario!
  before_action {tiene_permiso?(2)}  # Minimo administrador
  before_action do
    Rails.application.reload_routes!
    @no_render_busqueda_basica = true
  end

  # GET /usuarios_especie
  # GET /usuarios_especie.json
  def index
    @usuarios_especie = UsuarioEspecie.join_user_especies.order(:usuario_id).load
  end

  # GET /usuarios_especie/1
  # GET /usuarios_especie/1.json
  def show
  end

  # GET /usuarios_especie/new
  def new
    @usuario_especie = UsuarioEspecie.new
  end

  # GET /usuarios_especie/1/edit
  def edit
  end

  # POST /usuarios_especie
  # POST /usuarios_especie.json
  def create
    @usuario_especie = UsuarioEspecie.new(usuario_especie_params)

    respond_to do |format|
      if @usuario_especie.save
        format.html { redirect_to @usuario_especie, notice: 'Usuario especie was successfully created.' }
        format.json { render action: 'show', status: :created, location: @usuario_especie }
      else
        format.html { render action: 'new' }
        format.json { render json: @usuario_especie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /usuarios_especie/1
  # PATCH/PUT /usuarios_especie/1.json
  def update
    respond_to do |format|
      if @usuario_especie.update(usuario_especie_params)
        format.html { redirect_to @usuario_especie, notice: 'Usuario especie was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @usuario_especie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /usuarios_especie/1
  # DELETE /usuarios_especie/1.json
  def destroy
    @usuario_especie.destroy
    respond_to do |format|
      format.html { redirect_to usuarios_especie_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_usuario_especie
      @usuario_especie = UsuarioEspecie.join_user_especies.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def usuario_especie_params
      params.require(:usuario_especie).permit(:usuario_id, :especie_id)
    end
end
