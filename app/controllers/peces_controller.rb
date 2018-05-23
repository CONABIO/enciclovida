class PecesController < ApplicationController
  before_action do
    @no_render_busqueda_basica = true
  end
  before_action :set_pez, only: [:show, :edit, :update, :destroy]

  # GET /peces
  def index
    # Mega join =S (por eso se limita)
    @peces = Pez.select_joins_peces.join_criterios.join_propiedades.limit(90)
    #@peces = Pez.load
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
      redirect_to pez_path(@pez), notice: 'El pez fue creado satisfactoriamente.'
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
    @filtros =  Criterio.dame_filtros

    if params[:commit].present?
      @peces = Pez.filtros_peces
      @peces = @peces.where(especie_id: params[:especie_id]) if params[:especie_id].present?  # Busqueda por nombre científico o comunes

      @peces = @peces.where("valor_zonas like '%#{params[:semaforo]}%'" ) if params[:semaforo].present?
      @peces = @peces.where("propiedades.id = ?", params[:grupos]) if params[:grupos].present?
      @peces = @peces.where("criterios.id = ?", params[:tipo_capturas]) if params[:tipo_capturas].present?
      @peces = @peces.where("criterios.id = ?", params[:tipo_vedas]) if params[:tipo_vedas].present?
      @peces = @peces.where("criterios.id = ?", params[:procedencias]) if params[:procedencias].present?
      @peces = @peces.where("criterios.id = ?", params[:pesquerias]) if params[:pesquerias].present?
      @peces = @peces.where("criterios.id = ?", params[:nom]) if params[:nom].present?
      @peces = @peces.where("criterios.id = ?", params[:iucn]) if params[:iucn].present?

      @peces = @peces.where("propiedades.id = ?", params[:zonas]) if params[:zonas].present?

      @peces = @peces.where("valor_zonas like '%#{params[:semaforo_cnp]}%'" ) if params[:semaforo_cnp].present?

      @peces = @peces.where("valor_total BETWEEN #{params[:semaforo_vt].split(',').first.to_i} AND #{params[:semaforo_vt].split(',').last.to_i}") if params[:semaforo_vt].present?

      @peces = @peces.where("propiedades.id = ?", params[:grupos]) if params[:grupos].present?
      @peces = @peces.where("propiedades.id = ?", params[:zonas]) if params[:zonas].present?
      @peces = @peces.where("criterios.id = ?", params[:tipo_capturas]) if params[:tipo_capturas].present?
      @peces = @peces.where("criterios.id = ?", params[:tipo_vedas]) if params[:tipo_vedas].present?
      @peces = @peces.where("criterios.id = ?", params[:procedencias]) if params[:procedencias].present?
      @peces = @peces.where("criterios.id = ?", params[:pesquerias]) if params[:pesquerias].present?
      @peces = @peces.where("criterios.id = ?", params[:nom]) if params[:nom].present?
      @peces = @peces.where("criterios.id = ?", params[:iucn]) if params[:iucn].present?

      render :file => 'peces/resultados'

    end
  end

  def dameNombre
    tipo = params[:tipo]
    case tipo
    when 'cientifico'
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
    params.require(:pez).permit(:especie_id, peces_criterios_attributes: [:criterio_id, :id, :_destroy])
  end
end
