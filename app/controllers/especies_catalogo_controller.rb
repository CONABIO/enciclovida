class EspeciesCatalogoController < ApplicationController
  before_action :set_especie_catalogo, only: [:show, :edit, :update, :destroy]

  # GET /especies_catalogo
  # GET /especies_catalogo.json
  def index
    @especies_catalogo = EspecieCatalogo.all
  end

  # GET /especies_catalogo/1
  # GET /especies_catalogo/1.json
  def show
  end

  # GET /especies_catalogo/new
  def new
    @especie_catalogo = EspecieCatalogo.new
  end

  # GET /especies_catalogo/1/edit
  def edit
  end

  # POST /especies_catalogo
  # POST /especies_catalogo.json
  def create
    @especie_catalogo = EspecieCatalogo.new(especie_catalogo_params)

    respond_to do |format|
      if @especie_catalogo.save
        format.html { redirect_to @especie_catalogo, notice: 'Especie catalogo was successfully created.' }
        format.json { render action: 'show', status: :created, location: @especie_catalogo }
      else
        format.html { render action: 'new' }
        format.json { render json: @especie_catalogo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /especies_catalogo/1
  # PATCH/PUT /especies_catalogo/1.json
  def update
    respond_to do |format|
      if @especie_catalogo.update(especie_catalogo_params)
        format.html { redirect_to @especie_catalogo, notice: 'Especie catalogo was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @especie_catalogo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /especies_catalogo/1
  # DELETE /especies_catalogo/1.json
  def destroy
    @especie_catalogo.destroy
    respond_to do |format|
      format.html { redirect_to especies_catalogo_url }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_especie_catalogo
    begin
      @especie_catalogo = EspecieCatalogo.find(params[:id])
    rescue
      @especie_catalogo={:descripcion => nil}
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def especie_catalogo_params
    params[:especie_catalogo]
  end
end
