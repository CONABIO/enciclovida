class ListasController < ApplicationController
  before_action :set_lista, only: [:show, :edit, :update, :destroy]
  before_filter :entroAlSistema?, :only => [:show, :index, :new, :create]
  before_filter :only => [:edit, :update, :destroy] do |c|
    c.tienePermiso? @lista.usuario_id
  end

  # GET /listas
  # GET /listas.json
  def index
    @listas = Lista.where(:usuario_id => dameUsuario).paginate(:page => params[:page])
    @taxones ||=''
  end

  # GET /listas/1
  # GET /listas/1.json
  def show
    respond_to do |format|
      format.html
      format.csv { send_data Lista.to_csv(@lista), :filename => "#{@lista.nombre_lista}.csv" }
      #format.xls # { send_data @products.to_csv(col_sep: "\t") }
    end
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
    @lista.usuario_id=inicioSesion?
    @lista.columnas=params[:lista][:columnas].join(',')[1..-1]

    respond_to do |format|
      if @lista.save
        format.html { redirect_to @lista, notice: "La lista fue creada satisfactoriamente." }
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
    @lista.columnas=params[:lista][:columnas].join(',')

    respond_to do |format|
      if @lista.update(lista_params)
        format.html { redirect_to @lista, notice: 'La lista fue actualizada satisfactoriamente.' }
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
    @accion=params[:controller]
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def lista_params
    params.require(:lista).permit(:nombre_lista, :columnas, :formato, :esta_activa, :cadena_especies)
  end
end
