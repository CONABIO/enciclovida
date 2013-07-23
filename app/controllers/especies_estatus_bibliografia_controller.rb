class EspeciesEstatusBibliografiaController < ApplicationController
  before_action :set_especie_estatus_bibliografia, only: [:show, :edit, :update, :destroy]

  # GET /especies_estatus_bibliografia
  # GET /especies_estatus_bibliografia.json
  def index
    @especies_estatus_bibliografia = EspecieEstatusBibliografia.all
  end

  # GET /especies_estatus_bibliografia/1
  # GET /especies_estatus_bibliografia/1.json
  def show
  end

  # GET /especies_estatus_bibliografia/new
  def new
    @especie_estatus_bibliografia = EspecieEstatusBibliografia.new
  end

  # GET /especies_estatus_bibliografia/1/edit
  def edit
  end

  # POST /especies_estatus_bibliografia
  # POST /especies_estatus_bibliografia.json
  def create
    @especie_estatus_bibliografia = EspecieEstatusBibliografia.new(especie_estatus_bibliografia_params)

    respond_to do |format|
      if @especie_estatus_bibliografia.save
        format.html { redirect_to @especie_estatus_bibliografia, notice: 'Especie estatus bibliografia was successfully created.' }
        format.json { render action: 'show', status: :created, location: @especie_estatus_bibliografia }
      else
        format.html { render action: 'new' }
        format.json { render json: @especie_estatus_bibliografia.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /especies_estatus_bibliografia/1
  # PATCH/PUT /especies_estatus_bibliografia/1.json
  def update
    respond_to do |format|
      if @especie_estatus_bibliografia.update(especie_estatus_bibliografia_params)
        format.html { redirect_to @especie_estatus_bibliografia, notice: 'Especie estatus bibliografia was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @especie_estatus_bibliografia.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /especies_estatus_bibliografia/1
  # DELETE /especies_estatus_bibliografia/1.json
  def destroy
    @especie_estatus_bibliografia.destroy
    respond_to do |format|
      format.html { redirect_to especies_estatus_bibliografia_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_especie_estatus_bibliografia
      @especie_estatus_bibliografia = EspecieEstatusBibliografia.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def especie_estatus_bibliografia_params
      params[:especie_estatus_bibliografia]
    end
end
