class AdicionalesController < ApplicationController
  skip_before_filter :set_locale
  before_action :authenticate_usuario!
  before_action :set_adicional, only: [:show, :edit, :update, :destroy]
  layout false, only: [:edita_nom_comun]

  # GET /adicionales
  # GET /adicionales.json
  def index
    @adicionales = Adicional.all
  end

  # GET /adicionales/1
  # GET /adicionales/1.json
  def show
  end

  # GET /adicionales/new
  def new
    @adicional = Adicional.new
  end

  # GET /adicionales/1/edit
  def edit
  end

  # POST /adicionales
  # POST /adicionales.json
  def create
    @adicional = Adicional.new(adicional_params)

    respond_to do |format|
      if @adicional.save
        format.html { redirect_to @adicional, notice: 'Adicional was successfully created.' }
        format.json { render action: 'show', status: :created, location: @adicional }
      else
        format.html { render action: 'new' }
        format.json { render json: @adicional.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /adicionales/1
  # PATCH/PUT /adicionales/1.json
  def update
    respond_to do |format|
      if @adicional.update(adicional_params)
        format.html { redirect_to @adicional, notice: 'Adicional was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @adicional.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /adicionales/1
  # DELETE /adicionales/1.json
  def destroy
    @adicional.destroy
    respond_to do |format|
      format.html { redirect_to adicionales_url }
      format.json { head :no_content }
    end
  end

  # Para que puedan cambiar el nombre comun principal
  def edita_nom_comun
    begin
      @especie = Especie.find(params[:especie_id])
    rescue    #si no encontro el taxon
      render :_error
    end

    @nombres_comunes = @especie.nombres_comunes
    @adicional = @especie.adicional
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_adicional
      @adicional = Adicional.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def adicional_params
      params[:adicional]
    end
end
