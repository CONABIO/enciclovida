class CategoriasTaxonomicaController < ApplicationController
  before_action :set_categoria_taxonomica, only: [:show, :edit, :update, :destroy]

  # GET /categorias_taxonomica
  # GET /categorias_taxonomica.json
  def index
    @categorias_taxonomica = CategoriaTaxonomica.all
  end

  # GET /categorias_taxonomica/1
  # GET /categorias_taxonomica/1.json
  def show
  end

  # GET /categorias_taxonomica/new
  def new
    @categoria_taxonomica = CategoriaTaxonomica.new
  end

  # GET /categorias_taxonomica/1/edit
  def edit
  end

  # POST /categorias_taxonomica
  # POST /categorias_taxonomica.json
  def create
    @categoria_taxonomica = CategoriaTaxonomica.new(categoria_taxonomica_params)

    respond_to do |format|
      if @categoria_taxonomica.save
        format.html { redirect_to @categoria_taxonomica, notice: 'Categoria taxonomica was successfully created.' }
        format.json { render action: 'show', status: :created, location: @categoria_taxonomica }
      else
        format.html { render action: 'new' }
        format.json { render json: @categoria_taxonomica.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categorias_taxonomica/1
  # PATCH/PUT /categorias_taxonomica/1.json
  def update
    respond_to do |format|
      if @categoria_taxonomica.update(categoria_taxonomica_params)
        format.html { redirect_to @categoria_taxonomica, notice: 'Categoria taxonomica was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @categoria_taxonomica.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categorias_taxonomica/1
  # DELETE /categorias_taxonomica/1.json
  def destroy
    @categoria_taxonomica.destroy
    respond_to do |format|
      format.html { redirect_to categorias_taxonomica_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_categoria_taxonomica
      @categoria_taxonomica = CategoriaTaxonomica.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def categoria_taxonomica_params
      params[:categoria_taxonomica]
    end
end
