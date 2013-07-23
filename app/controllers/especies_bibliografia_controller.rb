class EspeciesBibliografiaController < ApplicationController
  before_action :set_especie_bibliografia, only: [:show, :edit, :update, :destroy]

  # GET /especies_bibliografia
  # GET /especies_bibliografia.json
  def index
    @especies_bibliografia = EspecieBibliografia.all
  end

  # GET /especies_bibliografia/1
  # GET /especies_bibliografia/1.json
  def show
  end

  # GET /especies_bibliografia/new
  def new
    @especie_bibliografia = EspecieBibliografia.new
  end

  # GET /especies_bibliografia/1/edit
  def edit
  end

  # POST /especies_bibliografia
  # POST /especies_bibliografia.json
  def create
    @especie_bibliografia = EspecieBibliografia.new(especie_bibliografia_params)

    respond_to do |format|
      if @especie_bibliografia.save
        format.html { redirect_to @especie_bibliografia, notice: 'Especie bibliografia was successfully created.' }
        format.json { render action: 'show', status: :created, location: @especie_bibliografia }
      else
        format.html { render action: 'new' }
        format.json { render json: @especie_bibliografia.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /especies_bibliografia/1
  # PATCH/PUT /especies_bibliografia/1.json
  def update
    respond_to do |format|
      if @especie_bibliografia.update(especie_bibliografia_params)
        format.html { redirect_to @especie_bibliografia, notice: 'Especie bibliografia was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @especie_bibliografia.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /especies_bibliografia/1
  # DELETE /especies_bibliografia/1.json
  def destroy
    @especie_bibliografia.destroy
    respond_to do |format|
      format.html { redirect_to especies_bibliografia_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_especie_bibliografia
      @especie_bibliografia = EspecieBibliografia.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def especie_bibliografia_params
      params[:especie_bibliografia]
    end
end
