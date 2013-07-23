class EspeciesEstatusController < ApplicationController
  before_action :set_especie_estatus, only: [:show, :edit, :update, :destroy]

  # GET /especies_estatus
  # GET /especies_estatus.json
  def index
    @especies_estatus = EspecieEstatus.all
  end

  # GET /especies_estatus/1
  # GET /especies_estatus/1.json
  def show
  end

  # GET /especies_estatus/new
  def new
    @especie_estatus = EspecieEstatus.new
  end

  # GET /especies_estatus/1/edit
  def edit
  end

  # POST /especies_estatus
  # POST /especies_estatus.json
  def create
    @especie_estatus = EspecieEstatus.new(especie_estatus_params)

    respond_to do |format|
      if @especie_estatus.save
        format.html { redirect_to @especie_estatus, notice: 'Especie estatus was successfully created.' }
        format.json { render action: 'show', status: :created, location: @especie_estatus }
      else
        format.html { render action: 'new' }
        format.json { render json: @especie_estatus.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /especies_estatus/1
  # PATCH/PUT /especies_estatus/1.json
  def update
    respond_to do |format|
      if @especie_estatus.update(especie_estatus_params)
        format.html { redirect_to @especie_estatus, notice: 'Especie estatus was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @especie_estatus.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /especies_estatus/1
  # DELETE /especies_estatus/1.json
  def destroy
    @especie_estatus.destroy
    respond_to do |format|
      format.html { redirect_to especies_estatus_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_especie_estatus
      @especie_estatus = EspecieEstatus.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def especie_estatus_params
      params[:especie_estatus]
    end
end
