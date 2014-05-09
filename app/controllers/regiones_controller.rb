class RegionesController < ApplicationController
  before_action :set_region, only: [:show, :edit, :update, :destroy]
  layout :false, only: :regiones

  # GET /regiones
  # GET /regiones.json
  def index
    @regiones = Region.all
  end

  # GET /regiones/1
  # GET /regiones/1.json
  def show
  end

  # GET /regiones/new
  def new
    @region = Region.new
  end

  # GET /regiones/1/edit
  def edit
  end

  # POST /regiones
  # POST /regiones.json
  def create
    @region = Region.new(region_params)

    respond_to do |format|
      if @region.save
        format.html { redirect_to @region, notice: 'Region was successfully created.' }
        format.json { render action: 'show', status: :created, location: @region }
      else
        format.html { render action: 'new' }
        format.json { render json: @region.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /regiones/1
  # PATCH/PUT /regiones/1.json
  def update
    respond_to do |format|
      if @region.update(region_params)
        format.html { redirect_to @region, notice: 'Region was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @region.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /regiones/1
  # DELETE /regiones/1.json
  def destroy
    @region.destroy
    respond_to do |format|
      format.html { redirect_to regiones_url }
      format.json { head :no_content }
    end
  end

  def regiones
    @nivel=params[:region_nivel].to_i + 1
    case @nivel
      when 1
        @regiones=Region.regiones_principales(params[:region])
      when 2, 3
        @regiones=Region.regiones_especificas(params[:region])
      else
        nil
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_region
      @region = Region.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def region_params
      params[:region]
    end
end
