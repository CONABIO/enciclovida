class Pmc::PropiedadesController < Pmc::PmcController

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
        format.html { redirect_to @propiedad, notice: 'La propiedad se creo correctamente.' }
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
        format.html { redirect_to @propiedad, notice: 'La propiedad se actualizó correctamente.' }
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
      format.html { redirect_to pmc_propiedades_path, notice: 'La propiedad se borró correctamente.' }
      format.json { head :no_content }
    end
  end

  def dame_tipo_propiedades
    res = if params[:q].present?
            propiedades = Pmc::Propiedad.select(:tipo_propiedad).where('tipo_propiedad REGEXP ?', Regexp.quote(params[:q])).where('ancestry IS NOT NULL').distinct
            propiedades.map { |p| { id: p.tipo_propiedad, value: p.tipo_propiedad } }
          else
            []
          end

    render json: res
  end


  private

  # Use callbacks to share common setup or constraints between actions.
  def set_propiedad
    @propiedad = Pmc::Propiedad.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def propiedad_params
    params.require(:pmc_propiedad).permit(:nombre_propiedad, :tipo_propiedad, :descripcion, :ancestry,
                                          criterios_attributes: [:id, :propiedad_id, :valor, :_destroy])
  end
end
