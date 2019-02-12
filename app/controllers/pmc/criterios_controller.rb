class Pmc::CriteriosController < Pmc::PmcController
  before_action :set_criterio, only: [:show, :edit, :update, :destroy]

  # GET /criterios
  # GET /criterios.json
  def index
    @criterios = Pmc::Criterio.all
  end

  # GET /criterios/1
  # GET /criterios/1.json
  def show
  end

  # GET /criterios/new
  def new
    @criterio = Pmc::Criterio.new
  end

  # GET /criterios/1/edit
  def edit
  end

  # POST /criterios
  # POST /criterios.json
  def create
    @criterio = Pmc::Criterio.new(criterio_params)

    respond_to do |format|
      if @criterio.save
        format.html { redirect_to @criterio, notice: 'Criterio was successfully created.' }
        format.json { render :show, status: :created, location: @criterio }
      else
        format.html { render :new }
        format.json { render json: @criterio.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /criterios/1
  # PATCH/PUT /criterios/1.json
  def update
    respond_to do |format|
      if @criterio.update(criterio_params)
        format.html { redirect_to @criterio, notice: 'Criterio was successfully updated.' }
        format.json { render :show, status: :ok, location: @criterio }
      else
        format.html { render :edit }
        format.json { render json: @criterio.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /criterios/1
  # DELETE /criterios/1.json
  def destroy
    @criterio.destroy
    respond_to do |format|
      format.html { redirect_to criterios_url, notice: 'Criterio was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_criterio
      @criterio = Pmc::Criterio.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def criterio_params
      params.fetch(:criterio, {})
    end
end
