class Plantid::PlantasController < Plantid::PlantidController

skip_before_action :set_locale

 before_action :set_planta, only: [:show, :edit, :update, :destroy]

  # GET /plantas
  # GET /plantas.json
  def index
    @plantid_plantas = Plantid::Planta.all
  end

  # GET /plantas/1
  # GET /plantas/1.json
  def show
    @plantid_planta = Plantid::Planta.all
  end

  # GET /plantas/new
  def new
    @form_params = { url: 'plantid/plantas', method: 'post' }
    @plantid_planta = Plantid::Planta.new
  end

  # GET /plantas/1/edit
  def edit
    @form_params = {}
  end

  # POST /plantas
  # POST /plantas.json
  def create
    @plantid_planta = Plantid::Planta.new(planta_params)

    respond_to do |format|
      if @plantid_planta.save
        format.html { redirect_to @plantid_planta, notice: 'Planta was successfully created.' }
        format.json { render :show, status: :created, location: @plantid_planta }
      else
        @form_params = { url: '/plantid/plantas', method: 'post' }
        format.html { render :new }
        format.json { render json: @plantid_planta.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /plantas/1
  # PATCH/PUT /plantas/1.json
  def update
    respond_to do |format|
      if @plantid_planta.update(planta_params)
        format.html { redirect_to @plantid_planta, notice: 'Planta was successfully updated.' }
        format.json { render :show, status: :ok, location: @plantid_planta }
      else
        format.html { render :edit }
        format.json { render json: @plantid_planta.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plantas/1
  # DELETE /plantas/1.json
  def destroy
    @plantid_planta.destroy
    respond_to do |format|
      format.html { redirect_to articles_url, notice: 'Planta was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_planta
      @plantid_planta = Plantid::Planta.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def planta_params
      params.require(:plantid_planta).permit(:especie_id, :nombre_cientifico, :nombre_comun, :nombre_comunes, :usuario_id,  bibliografias_attributes: [:id, :nombre_biblio, :destroy])
    end
end
