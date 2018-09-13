class Metamares::FrontController < ApplicationController
  #before_action :set_estatuse, only: [:show, :edit, :update, :destroy]

  # Muestra todos proyectos para el publico en general, en forma resumida para buscar
  def index
    @proyectos = Metamares::Proyecto.all
  end

  # Muestra toda la informacion relacionada a un proyecto en cuestion
  def show
  end

  # Crea un nuevo proyecto
  def new
    @estatuse = Estatus.new
  end

  # Edita proyectos propios
  def edit
  end

  # Para guardar el proyecto
  def create
    @estatuse = Estatus.new(estatuse_params)

    respond_to do |format|
      if @estatuse.save
        format.html { redirect_to @estatuse, notice: 'Estatus was successfully created.' }
        format.json { render action: 'show', status: :created, location: @estatuse }
      else
        format.html { render action: 'new' }
        format.json { render json: @estatuse.errors, status: :unprocessable_entity }
      end
    end
  end

  # Para actualizar el proyecto
  def update
    respond_to do |format|
      if @estatuse.update(estatuse_params)
        format.html { redirect_to @estatuse, notice: 'Estatus was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @estatuse.errors, status: :unprocessable_entity }
      end
    end
  end

  # Elimina un proyecto propio
  def destroy
    @estatuse.destroy
    respond_to do |format|
      format.html { redirect_to estatuses_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_estatuse
      @estatuse = Estatus.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def estatuse_params
      params[:estatuse]
    end
end
