class PecesController < ApplicationController
  before_action do
    @no_render_busqueda_basica = true
  end
  before_action :set_pez, only: [:show, :edit, :update, :destroy]

  # GET /peces
  def index
    @peces = Pez.select_joins_peces.join_criterios.join_propiedades.limit(90)
  end

  # GET /peces/1
  def show
    @pez = Pez.find(params[:id]).criterios.first.propiedad
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

  def busqueda
    @filtros = {grupos: Propiedad.grupos_conabio, zonas: Propiedad.zonas, procedencia: Propiedad.procedencias}
    #@filtros = {nombres: Pez.nombres_peces, grupos: Propiedad.grupos_conabio, zonas: Propiedad.zonas, procedencia: Propiedad.procedencias}
    #@filtros = {ncientifico: p.map(&:nombrecientifico), ncomunes: p.map(&:nombrecomunes)}
    @peces = Pez.select_joins_peces.join_criterios.join_propiedades.where(especie_id: params[:ncientifico_id]) if params[:commit].present?
  end

  def dameNombre
    tipo = params[:tipo]
    case tipo
    when 'cientifico'
      #render json: Pez.select(:especie_id, :nombre_cientifico).where("nombre_cientifico LIKE ?", "%#{params[:term]}%").map{|k| [k.nombre_cientifico,k.especie_id.to_s]}.to_s.to_json
      render json: Pez.nombres_cientificos_peces.where("nombre_cientifico LIKE ?", "%#{params[:term]}%").to_json
    when 'comunes'
      render json: Pez.nombres_comunes_peces.where("nombres_comunes LIKE ?", "%#{params[:term]}%").to_json
    else
      render json: [{error: 'no encontre'}].to_json
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pez
      @pez = Pez.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def pez_params
      params.require(:pez).permit(peces: [:especie_id, :valor_total, :valor_zonas, :tipo_imagen, :imagen, :nombre_cientifico, :nombres_comunes], criterio: [:valor, :anio], propiedad: [:nombre_propiedad,:tipo_propiedad])
    end
end