class ListasController < ApplicationController
  # Para crear listas de taxones o para exportar los datos y mandarlos al correo, y tambien valida el excel de estatales

  skip_before_action :set_locale, only: [:aniade_taxones_seleccionados, :dame_listas, :create, :update, :destroy]
  before_action :authenticate_usuario!, only: [:index, :new, :edit, :create, :update, :destroy, :aniade_taxones_seleccionados]
  before_action :set_lista, only: [:show, :edit, :update, :destroy]

  before_action only: [:edit, :update, :destroy] do
    permiso = es_propietario?(@lista)
    render :_error unless permiso
  end

  before_action only: :aniade_taxones_seleccionados do
    if params[:listas].present?
      @listas = []
      con_error = false

      params[:listas].each do |lista_id|
        lista = Lista.find(lista_id)
        permiso = es_propietario?(lista)
        con_error = true unless permiso

        if permiso
          @listas << lista
        end
      end

      render :_error if con_error
    else
      render :_error and return
    end
  end

  layout false, :only => [:dame_listas, :aniade_taxones_seleccionados]

  # GET /listas
  # GET /listas.json
  def index
    @listas = Lista.where(:usuario_id => current_usuario.id).limit(50)
    @taxones = ''
  end

  # GET /listas/1
  # GET /listas/1.json
  def show
    respond_to do |format|
      format.html
      format.csv { send_data @lista.to_csv, :filename => "#{@lista.nombre_lista}.csv" }
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
    @lista.usuario_id = current_usuario.id
    @lista.columnas=params[:columnas].join(',')

    respond_to do |format|
      if @lista.save
        format.html { redirect_to @lista, notice: 'La lista fue creada satisfactoriamente.' }
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
    @lista.columnas = params[:columnas].join(',')

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

  # Consumido con ajax
  def dame_listas
    if usuario_signed_in?
      @listas = Lista.where(:usuario_id => current_usuario.id).limit(10)
    else
      render text: 'Para poder ver tus listas necesitas iniciar sesión'
    end
  end

  # Aniade los taxones seleccionados con las cajas
  def aniade_taxones_seleccionados
    notice = if params[:especies].present?
               @listas.each do |lista|
                 lista = Lista.find(lista)
                 lista.cadena_especies.present? ? lista.cadena_especies+= ',' + params[:especies].join(',') :
                     lista.cadena_especies = params[:especies].join(',')
                 lista.save
               end
               'Taxones incluidos correctamente.'
             else
               'Debes seleccionar por lo menos una lista y un taxon para poder incluirlo.'
             end

    redirect_to :back, :notice => notice
  end

  # Aniade todos los taxones que salieron en el query
  def aniade_taxones_query
  end

  # Envia por correo los taxones seleccionados con las cajas
  def envia_taxones_seleccionados
  end

  # Envia por correo los taxones que saieron con el query
  def envia_taxones_query
  end


  private

  # Use callbacks to share common setup or constraints between actions.
  def set_lista
    begin
      @lista = Lista.find(params[:id])
      @accion=params[:controller]
    rescue
      render :_error
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def lista_params
    params.require(:lista).permit(:nombre_lista, :columnas, :formato, :esta_activa, :cadena_especies)
  end
end
