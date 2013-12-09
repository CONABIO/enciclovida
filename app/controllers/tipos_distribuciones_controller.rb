class TiposDistribucionesController < ApplicationController
  before_action :set_tipo_distribucion, only: [:show, :edit, :update, :destroy]

  # GET /tipos_distribuciones
  # GET /tipos_distribuciones.json
  def index
    @tipos_distribuciones = TipoDistribucion.all.order('descripcion ASC')
  end

  # GET /tipos_distribuciones/1
  # GET /tipos_distribuciones/1.json
  def show
  end

  # GET /tipos_distribuciones/new
  def new
    @tipo_distribucion = TipoDistribucion.new
  end

  # GET /tipos_distribuciones/1/edit
  def edit
  end

  # POST /tipos_distribuciones
  # POST /tipos_distribuciones.json
  def create
    @tipo_distribucion = TipoDistribucion.new(tipo_distribucion_params)

    respond_to do |format|
      if @tipo_distribucion.save
        format.html { redirect_to @tipo_distribucion, notice: 'Tipo distribucion was successfully created.' }
        format.json { render action: 'show', status: :created, location: @tipo_distribucion }
      else
        format.html { render action: 'new' }
        format.json { render json: @tipo_distribucion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tipos_distribuciones/1
  # PATCH/PUT /tipos_distribuciones/1.json
  def update
    respond_to do |format|
      if @tipo_distribucion.update(tipo_distribucion_params)
        format.html { redirect_to @tipo_distribucion, notice: 'Tipo distribucion was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @tipo_distribucion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tipos_distribuciones/1
  # DELETE /tipos_distribuciones/1.json
  def destroy
    @tipo_distribucion.destroy
    respond_to do |format|
      format.html { redirect_to tipos_distribuciones_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tipo_distribucion
      @tipo_distribucion = TipoDistribucion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tipo_distribucion_params
      params[:tipo_distribucion]
    end
end
