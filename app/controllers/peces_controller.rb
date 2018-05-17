class PecesController < ApplicationController
  before_action :set_pez, only: [:show, :edit, :update, :destroy]

  # GET /peces
  def index
    @peces = Pez.select_joins_peces.join_criterios.join_propiedades
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
    @pez = Pez.new(pez_params)

    if @pez.save
      redirect_to @pez, notice: 'Pez was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /peces/1
  def update
    if @pez.update(pez_params)
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
    def set_pez
      @pez = Pez.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def pez_params
      params.require(:pez).permit(:especie_id, :valor_total_promedio, :valor, :anio, :nombre_propiedad, :tipo_propiedad)
    end
end
