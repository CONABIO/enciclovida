class Plantid::PlantasController < Plantid::PlantidController

skip_before_action :set_locale

 before_action :set_planta, only: [:show, :edit, :update, :destroy]

  # GET /plantas
  # GET /plantas.json
  def index
    @plantid_pi_plantas = Plantid::PiPlanta.all
  end

  # GET /plantas/1
  # GET /plantas/1.json
  def show
    @plantid_pi_planta = Plantid::PiPlanta.find(params[:id])
  end

  # GET /plantas/new
  def new
    @no_render_busqueda_basica = true
    @plantid_pi_planta = Plantid::PiPlanta.new
    @plantid_pi_planta.usuario_id = '1'
  end

  # GET /plantas/1/edit
  def edit
    @no_render_busqueda_basica = true
    @form_params = {}

  end

  # POST /plantas
  # POST /plantas.json
  def create
    @plantid_pi_planta = Plantid::PiPlanta.new(planta_params)
    @plantid_pi_planta.usuario_id = '1'

    puts @plantid_pi_planta.valid?
    puts @plantid_pi_planta.errors.inspect


    respond_to do |format|
      if @plantid_pi_planta.save
        format.html { redirect_to @plantid_pi_planta, notice: 'La Planta fue creada con exito.' }
        format.json { render :show, status: :created, location: @plantid_pi_planta }
      else
        @form_params = { url: '/plantid/plantas', method: 'post' }
        format.html { render :new }
        format.json { render json: @plantid_pi_planta.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /plantas/1
  # PATCH/PUT /plantas/1.json
  def update
    respond_to do |format|
      if @plantid_pi_planta.update(planta_params)
        format.html { redirect_to @plantid_pi_planta, notice: 'Planta fue actualizada con exito.' }
        format.json { render :show, status: :ok, location: @plantid_pi_planta }
      else
        format.html { render :edit }
        format.json { render json: @plantid_pi_planta.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plantas/1
  # DELETE /plantas/1.json
  def destroy
    @plantid_pi_planta.destroy
    respond_to do |format|
      format.html { redirect_to plantid_plantas_url, notice: 'Planta fue destruida con exito.' }
      format.json { head :no_content }
    end
  end

   def load_bibliosuggestions
    @find = Bibliografia.select(:id,:CitaCompleta).where("CitaCompleta LIKE ?","%#{params[:q]}%")
    puts @find.inspect
    render json: @find
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_planta
      @plantid_pi_planta = Plantid::PiPlanta.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def planta_params
      params.require(:plantid_pi_planta).permit(:especie_id, :nombre_cientifico, :nombre_comun, :nombres_comunes, :usuario_id,piimagen_attributes: [:id, :imagen, :remote_imagen_url,  :_destroy] ,pibibliografias_attributes: [:id, :nombre_biblio, :_destroy])
    end
end
