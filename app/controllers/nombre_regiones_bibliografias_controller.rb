class NombreRegionesBibliografiasController < ApplicationController
  before_action :set_nombre_region_bibliografia, only: [:show, :edit, :update, :destroy]

  # GET /nombre_regiones_bibliografias
  # GET /nombre_regiones_bibliografias.json
  def index
    @nombre_regiones_bibliografias = NombreRegionBibliografia.all
  end

  # GET /nombre_regiones_bibliografias/1
  # GET /nombre_regiones_bibliografias/1.json
  def show
  end

  # GET /nombre_regiones_bibliografias/new
  def new
    @nombre_region_bibliografia = NombreRegionBibliografia.new
  end

  # GET /nombre_regiones_bibliografias/1/edit
  def edit
  end

  # POST /nombre_regiones_bibliografias
  # POST /nombre_regiones_bibliografias.json
  def create
    @nombre_region_bibliografia = NombreRegionBibliografia.new(nombre_region_bibliografia_params)

    respond_to do |format|
      if @nombre_region_bibliografia.save
        format.html { redirect_to @nombre_region_bibliografia, notice: 'Nombre region bibliografia was successfully created.' }
        format.json { render action: 'show', status: :created, location: @nombre_region_bibliografia }
      else
        format.html { render action: 'new' }
        format.json { render json: @nombre_region_bibliografia.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /nombre_regiones_bibliografias/1
  # PATCH/PUT /nombre_regiones_bibliografias/1.json
  def update
    respond_to do |format|
      if @nombre_region_bibliografia.update(nombre_region_bibliografia_params)
        format.html { redirect_to @nombre_region_bibliografia, notice: 'Nombre region bibliografia was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @nombre_region_bibliografia.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /nombre_regiones_bibliografias/1
  # DELETE /nombre_regiones_bibliografias/1.json
  def destroy
    @nombre_region_bibliografia.destroy
    respond_to do |format|
      format.html { redirect_to nombre_regiones_bibliografias_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_nombre_region_bibliografia
      @nombre_region_bibliografia = NombreRegionBibliografia.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def nombre_region_bibliografia_params
      params[:nombre_region_bibliografia]
    end
end
