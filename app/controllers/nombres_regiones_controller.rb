class NombresRegionesController < ApplicationController
  before_action :set_nombr_regione, only: [:show, :edit, :update, :destroy]

  # GET /nombres_regiones
  # GET /nombres_regiones.json
  def index
    @nombres_regiones = NombreRegion.all
  end

  # GET /nombres_regiones/1
  # GET /nombres_regiones/1.json
  def show
  end

  # GET /nombres_regiones/new
  def new
    @nombr_regione = NombreRegion.new
  end

  # GET /nombres_regiones/1/edit
  def edit
  end

  # POST /nombres_regiones
  # POST /nombres_regiones.json
  def create
    @nombr_regione = NombreRegion.new(nombr_regione_params)

    respond_to do |format|
      if @nombr_regione.save
        format.html { redirect_to @nombr_regione, notice: 'Nombre region was successfully created.' }
        format.json { render action: 'show', status: :created, location: @nombr_regione }
      else
        format.html { render action: 'new' }
        format.json { render json: @nombr_regione.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /nombres_regiones/1
  # PATCH/PUT /nombres_regiones/1.json
  def update
    respond_to do |format|
      if @nombr_regione.update(nombr_regione_params)
        format.html { redirect_to @nombr_regione, notice: 'Nombre region was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @nombr_regione.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /nombres_regiones/1
  # DELETE /nombres_regiones/1.json
  def destroy
    @nombr_regione.destroy
    respond_to do |format|
      format.html { redirect_to nombres_regiones_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_nombr_regione
      @nombr_regione = NombreRegion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def nombr_regione_params
      params[:nombr_regione]
    end
end
