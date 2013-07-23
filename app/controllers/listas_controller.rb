class ListasController < ApplicationController
  before_action :set_lista, only: [:show, :edit, :update, :destroy]

  # GET /listas
  # GET /listas.json
  def index
    @listas = Lista.all
  end

  # GET /listas/1
  # GET /listas/1.json
  def show
  end

  # GET /listas/new
  def new
    @lista = Lista.new
  end

  # GET /listas/1/edit
  def edit
  end

  # POST /listas
  # POST /listas.json
  def create
    @lista = Lista.new(lista_params)

    respond_to do |format|
      if @lista.save
        format.html { redirect_to @lista, notice: 'Lista was successfully created.' }
        format.json { render action: 'show', status: :created, location: @lista }
      else
        format.html { render action: 'new' }
        format.json { render json: @lista.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /listas/1
  # PATCH/PUT /listas/1.json
  def update
    respond_to do |format|
      if @lista.update(lista_params)
        format.html { redirect_to @lista, notice: 'Lista was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @lista.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /listas/1
  # DELETE /listas/1.json
  def destroy
    @lista.destroy
    respond_to do |format|
      format.html { redirect_to listas_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lista
      @lista = Lista.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lista_params
      params[:lista]
    end
end
