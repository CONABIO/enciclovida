class EspeciesRegionesController < ApplicationController
  before_action :set_especie_region, only: [:show, :edit, :update, :destroy]
  autocomplete :region, :nombre, :column_name => :nombre_region, :full => true, :display_value => :personalizaBusqueda,
               :extra_data => [:nombre_region, :tipo_region_id, :ancestry], :limit => 30

  # GET /especies_regiones
  # GET /especies_regiones.json
  def index
    @especies_regiones = EspecieRegion.all
  end

  # GET /especies_regiones/1
  # GET /especies_regiones/1.json
  def show
  end

  # GET /especies_regiones/new
  def new
    @especie_region = EspecieRegion.new
  end

  # GET /especies_regiones/1/edit
  def edit
  end

  # POST /especies_regiones
  # POST /especies_regiones.json
  def create
    @especie_region = EspecieRegion.new(especie_region_params)

    respond_to do |format|
      if @especie_region.save
        format.html { redirect_to @especie_region, notice: 'Especie region was successfully created.' }
        format.json { render action: 'show', status: :created, location: @especie_region }
      else
        format.html { render action: 'new' }
        format.json { render json: @especie_region.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /especies_regiones/1
  # PATCH/PUT /especies_regiones/1.json
  def update
    respond_to do |format|
      if @especie_region.update(especie_region_params)
        format.html { redirect_to @especie_region, notice: 'Especie region was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @especie_region.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /especies_regiones/1
  # DELETE /especies_regiones/1.json
  def destroy
    @especie_region.destroy
    respond_to do |format|
      format.html { redirect_to especies_regiones_url }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_especie_region
    begin
      @especie_region = EspecieRegion.find(params[:id])
    rescue
      @especie_region={:nombre_region => nil}
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def especie_region_params
    params[:especie_region]
  end
end
