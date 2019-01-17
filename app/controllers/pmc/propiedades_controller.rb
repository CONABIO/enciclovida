class Pmc::PropiedadesController < ApplicationController

  before_action :set_propiedad, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_usuario!
  before_action do
    tiene_permiso?('AdminPeces', true)
  end

  # GET /propiedades
  # GET /propiedades.json
  def index
    @propiedades = Pmc::Propiedad.all.order(ancestry: :asc)
  end

  # GET /propiedades/1
  # GET /propiedades/1.json
  def show
  end

  # GET /propiedades/new
  def new
    @propiedad = Pmc::Propiedad.new
  end

  # GET /propiedades/1/edit
  def edit
  end

  # POST /propiedades
  # POST /propiedades.json
  def create
    @propiedad = Pmc::Propiedad.new(propiedad_params)

    respond_to do |format|
      if @propiedad.save
        format.html { redirect_to @propiedad, notice: 'Propiedad was successfully created.' }
        format.json { render :show, status: :created, location: @propiedad }
      else
        format.html { render :new }
        format.json { render json: @propiedad.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /propiedades/1
  # PATCH/PUT /propiedades/1.json
  def update
    respond_to do |format|
      if @propiedad.update(propiedad_params)
        format.html { redirect_to @propiedad, notice: 'Propiedad was successfully updated.' }
        format.json { render :show, status: :ok, location: @propiedad }
      else
        format.html { render :edit }
        format.json { render json: @propiedad.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /propiedades/1
  # DELETE /propiedades/1.json
  def destroy
    @propiedad.destroy
    respond_to do |format|
      format.html { redirect_to propiedades_url, notice: 'Propiedad was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_propiedad
      @propiedad = Pmc::Propiedad.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def propiedad_params
      params.require(:pmc_propiedad).permit(:nombre_propiedad, :tipo_propiedad, :descripcion, :ancestry)
    end
end
