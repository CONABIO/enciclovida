class TiposRegionesController < ApplicationController
  before_action :set_tipo_region, only: [:show, :edit, :update, :destroy]

  # GET /tipos_regiones
  # GET /tipos_regiones.json
  def index
    @tipos_regiones = TipoRegion.all
  end

  # GET /tipos_regiones/1
  # GET /tipos_regiones/1.json
  def show
  end

  # GET /tipos_regiones/new
  def new
    @tipo_region = TipoRegion.new
  end

  # GET /tipos_regiones/1/edit
  def edit
  end

  # POST /tipos_regiones
  # POST /tipos_regiones.json
  def create
    @tipo_region = TipoRegion.new(tipo_region_params)

    respond_to do |format|
      if @tipo_region.save
        format.html { redirect_to @tipo_region, notice: 'Tipo region was successfully created.' }
        format.json { render action: 'show', status: :created, location: @tipo_region }
      else
        format.html { render action: 'new' }
        format.json { render json: @tipo_region.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tipos_regiones/1
  # PATCH/PUT /tipos_regiones/1.json
  def update
    respond_to do |format|
      if @tipo_region.update(tipo_region_params)
        format.html { redirect_to @tipo_region, notice: 'Tipo region was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @tipo_region.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tipos_regiones/1
  # DELETE /tipos_regiones/1.json
  def destroy
    @tipo_region.destroy
    respond_to do |format|
      format.html { redirect_to tipos_regiones_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tipo_region
      @tipo_region = TipoRegion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tipo_region_params
      params[:tipo_region]
    end
end
