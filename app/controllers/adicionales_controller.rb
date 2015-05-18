class AdicionalesController < ApplicationController
  skip_before_filter :set_locale
  before_action :authenticate_usuario!
  before_action do
    permiso = tiene_permiso?(10)  # Minimo curador basico
    render :_error unless permiso
  end
  before_action :set_adicional, only: [:show, :edit, :update, :destroy]
  before_action :actualiza_nom_comun_params, only: :actualiza_nom_comun
  layout false, only: [:edita_nom_comun]

  # GET /adicionales
  # GET /adicionales.json
  def index
    @adicionales = Adicional.all
  end

  # GET /adicionales/1
  # GET /adicionales/1.json
  def show
  end

  # GET /adicionales/new
  def new
    @adicional = Adicional.new
  end

  # GET /adicionales/1/edit
  def edit
  end

  # POST /adicionales
  # POST /adicionales.json
  def create
    @adicional = Adicional.new(adicional_params)

    respond_to do |format|
      if @adicional.save
        format.html { redirect_to @adicional, notice: 'Adicional was successfully created.' }
        format.json { render action: 'show', status: :created, location: @adicional }
      else
        format.html { render action: 'new' }
        format.json { render json: @adicional.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /adicionales/1
  # PATCH/PUT /adicionales/1.json
  def update
    respond_to do |format|
      if @adicional.update(adicional_params)
        format.html { redirect_to @adicional, notice: 'Adicional was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @adicional.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /adicionales/1
  # DELETE /adicionales/1.json
  def destroy
    @adicional.destroy
    respond_to do |format|
      format.html { redirect_to adicionales_url }
      format.json { head :no_content }
    end
  end

  # Para que puedan cambiar el nombre comun principal
  def edita_nom_comun
    begin
      @especie = Especie.find(params[:especie_id])
    rescue    #si no encontro el taxon
      render :_error
    end

    render :_error if !@adicional = @especie.adicional
    @nombres_comunes = @especie.nombres_comunes
    if @nombres_comunes.any?
      @nombres_comunes = @nombres_comunes.distinct.map{|nc| ["#{nc.nombre_comun.humanizar} (#{nc.lengua})", nc.nombre_comun.humanizar]}.sort
    end
  end

  def actualiza_nom_comun
    @adicional = Adicional.find(params[:adicional][:id])

    Rails.logger.info "---#{}"
    if params[:adicional][:text_nom_comun].present?
      @adicional.nombre_comun_principal = params[:adicional][:text_nom_comun]
    elsif params[:adicional][:select_nom_comun].present?
      @adicional.nombre_comun_principal = params[:adicional][:select_nom_comun]
    else
      @adicional.nombre_comun_principal = nil
    end

    if @adicional.nombre_comun_principal_changed?
      if @adicional.save
        redirect_to especy_url(@adicional.especie_id), notice: 'El nombre común principal se actualizó correctamente.'
      else
        redirect_to especy_url(@adicional.especie_id), notice: 'Lo sentimos en este momento no se puede actualizar.'
      end
    else
      redirect_to especy_url(@adicional.especie_id), notice: 'No se detecto ningun cambio en el nombre común.'
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_adicional
    @adicional = Adicional.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def adicional_params
    params[:adicional]
  end

  # Parametros permitidos para actualizar el nombre comun
  def actualiza_nom_comun_params
    params.require(:adicional).permit(:id, :select_nom_comun, :text_nom_comun)
  end
end
