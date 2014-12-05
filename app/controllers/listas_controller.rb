class ListasController < ApplicationController

  skip_before_filter :set_locale, only: [:aniade_taxones, :dame_listas, :create, :update]
  before_action :authenticate_usuario!, only: [:index, :new, :edit, :create, :update, :destroy, :dame_listas, :aniade_taxones]
  before_action :es_propietario?, only: [:edit, :update, :destroy]
  before_action 'es_propietario?(true)', only: [:aniade_taxones]
  before_action :set_lista, only: [:show]
  layout false, :only => [:dame_listas, :aniade_taxones]

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

  def dame_listas
    @listas = Lista.where(:usuario_id => current_usuario.id)
  end

  def aniade_taxones
    notice = if params[:especies].present?
               params[:listas].each do |lista|
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

  def es_propietario?(aniade_taxones = false)
    # Para la parte de aniadir taxones
    if aniade_taxones
      if params[:listas].present?
        begin
          listas = Lista.find(params[:listas])
          listas.each do |l|
            render :_error unless current_usuario.id == l.usuario_id
          end
        rescue
          render :_error
        end
      else
        redirect_to :back, :notice => 'Debes seleccionar por lo menos un taxon para poder incluirlo.'
      end
    else
      set_lista
      render :_error unless current_usuario.id == @lista.usuario_id
    end
  end
end
