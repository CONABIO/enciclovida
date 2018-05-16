class PecesController < ApplicationController
  before_action :set_pece, only: [:show, :edit, :update, :destroy]

  # GET /peces
  def index
    @peces = Pez.all
  end

  # GET /peces/1
  def show
  end

  # GET /peces/new
  def new
    @pez = Pez.new
  end

  # GET /peces/1/edit
  def edit
  end

  # POST /peces
  def create
    @pez = Pez.new(pece_params)

    if @pez.save
      redirect_to @pez, notice: 'Pez was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /peces/1
  def update
    if @pez.update(pece_params)
      redirect_to @pez, notice: 'Pez was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /peces/1
  def destroy
    @pez.destroy
    redirect_to peces_url, notice: 'Pez was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pece
      @pez = Pez.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def pece_params
      params.require(:pez).permit(:especie_id, :valor_total_promedio, :valor, :anio, :nombre_propiedad, :tipo_propiedad)
    end
end
