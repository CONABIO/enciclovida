class RegionesMapasController < ApplicationController
  before_action :set_region_mapa, only: [:show, :edit, :update, :destroy]

  # GET /regiones_mapas
  # GET /regiones_mapas.json
  def index
    @regiones_mapas = RegionMapa.all
  end

  # GET /regiones_mapas/1
  # GET /regiones_mapas/1.json
  def show
  end

  # GET /regiones_mapas/new
  def new
    @region_mapa = RegionMapa.new
  end

  # GET /regiones_mapas/1/edit
  def edit
  end

  # POST /regiones_mapas
  # POST /regiones_mapas.json
  def create
    @region_mapa = RegionMapa.new(region_mapa_params)

    respond_to do |format|
      if @region_mapa.save
        format.html { redirect_to @region_mapa, notice: 'Region mapa was successfully created.' }
        format.json { render action: 'show', status: :created, location: @region_mapa }
      else
        format.html { render action: 'new' }
        format.json { render json: @region_mapa.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /regiones_mapas/1
  # PATCH/PUT /regiones_mapas/1.json
  def update
    respond_to do |format|
      if @region_mapa.update(region_mapa_params)
        format.html { redirect_to @region_mapa, notice: 'Region mapa was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @region_mapa.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /regiones_mapas/1
  # DELETE /regiones_mapas/1.json
  def destroy
    @region_mapa.destroy
    respond_to do |format|
      format.html { redirect_to regiones_mapas_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_region_mapa
      @region_mapa = RegionMapa.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def region_mapa_params
      params[:region_mapa]
    end
end
