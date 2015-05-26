class ComentariosController < ApplicationController
  skip_before_filter :set_locale, only: [:create, :update, :destroy]
  before_action :set_comentario, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_usuario!, :only => [:index, :show, :update, :destroy]
  before_action :only => [:index, :show, :update, :destroy] do
    permiso = tiene_permiso?(100)  # Minimo administrador
    render :_error unless permiso
  end

  # GET /comentarios
  # GET /comentarios.json
  def index
    @comentarios = Comentario.all
  end

  # GET /comentarios/1
  # GET /comentarios/1.json
  def show
  end

  # GET /comentarios/new
  def new
    @comentario = Comentario.new
  end

  # GET /comentarios/1/edit
  def edit
  end

  # POST /comentarios
  # POST /comentarios.json
  def create
    @comentario = Comentario.new(comentario_params)

    respond_to do |format|
      if @comentario.save
        format.html { redirect_to @comentario, notice: 'Comentario was successfully created.' }
        format.json { render action: 'show', status: :created, location: @comentario }
      else
        format.html { render action: 'new' }
        format.json { render json: @comentario.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comentarios/1
  # PATCH/PUT /comentarios/1.json
  def update
    respond_to do |format|
      if @comentario.update(comentario_params)
        format.html { redirect_to @comentario, notice: 'Comentario was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @comentario.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comentarios/1
  # DELETE /comentarios/1.json
  def destroy
    @comentario.destroy
    respond_to do |format|
      format.html { redirect_to comentarios_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comentario
      @comentario = Comentario.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comentario_params
      params[:comentario]
    end
end
