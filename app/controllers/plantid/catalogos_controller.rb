class Plantid::CatalogosController < ApplicationController

skip_before_action :set_locale

 before_action :set_planta, only: [:show, :edit, :update, :destroy]

  # GET /plantas
  # GET /plantas.json
  def index
    @plantid_catalogos = Plantid::Catalogo.all
  end

  # GET /plantas/1
  # GET /plantas/1.json
  def show
    @plantid_catalogo = Plantid::Catalogo.find(params[:id])
  end

  # GET /plantas/new
  def new
    #@form_params = { url: 'plantid/plantas', method: 'post' }
    @plantid_catalogo = Plantid::Catalogo.new
  end

  # GET /plantas/1/edit
  def edit
    @form_params = {}
  end

  # POST /plantas
  # POST /plantas.json
  def create
    @plantid_catalogo = Plantid::Catalogo.new(catalogo_params)

    respond_to do |format|
      if @plantid_planta.save
        format.html { redirect_to @plantid_planta_catalogo, notice: 'El catalogo fue creada con exito.' }
        format.json { render :show, status: :created, location: @plantid_catalogo }
      else
        @form_params = { url: '/plantid/plantas', method: 'post' }
        format.html { render :new }
        format.json { render json: @plantid_catalogo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /plantas/1
  # PATCH/PUT /plantas/1.json
  def update
    respond_to do |format|
      if @plantid_catalogo.update(planta_params)
        format.html { redirect_to @plantid_planta_catalogo, notice: 'Catalogo fue actualizado con éxito.' }
        format.json { render :show, status: :ok, location: @plantid_catalogo }
      else
        format.html { render :edit }
        format.json { render json: @plantid_catalogo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plantas/1
  # DELETE /plantas/1.json
  def destroy
    @plantid_catalogo.destroy
    respond_to do |format|
      format.html { redirect_to plantid_catalogos_url, notice: 'Catalogo fue destruida con exito.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_catalogo
      @plantid_catalogo = Plantid::Catalogo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def catalogo_params
      params.require(:plantid_catalogo).permit(:descripcion,:catalogo_principal,:catalogo_intermedia)
    end
end
