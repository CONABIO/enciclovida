class RegionesMapasController < ApplicationController
  skip_before_filter :verify_authenticity_token, :set_locale
  before_action :set_region_mapa, only: [:show, :edit, :update, :destroy]
  layout false, :only => [:dame_region]

  # GET /regiones_mapas
  # GET /regiones_mapas.json
  def index
    @regiones_mapas = RegionMapa.all
  end

  # GET /regiones_mapas/1
  # GET /regiones_mapas/1.json
  def show
  end

  # GET /regiones_mapas/new
  def new
    @region_mapa = RegionMapa.new
  end

  # GET /regiones_mapas/1/edit
  def edit
  end

  # POST /regiones_mapas
  # POST /regiones_mapas.json
  def create
    @region_mapa = RegionMapa.new(region_mapa_params)

    respond_to do |format|
      if @region_mapa.save
        format.html { redirect_to @region_mapa, notice: 'Region mapa was successfully created.' }
        format.json { render action: 'show', status: :created, location: @region_mapa }
      else
        format.html { render action: 'new' }
        format.json { render json: @region_mapa.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /regiones_mapas/1
  # PATCH/PUT /regiones_mapas/1.json
  def update
    respond_to do |format|
      if @region_mapa.update(region_mapa_params)
        format.html { redirect_to @region_mapa, notice: 'Region mapa was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @region_mapa.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /regiones_mapas/1
  # DELETE /regiones_mapas/1.json
  def destroy
    @region_mapa.destroy
    respond_to do |format|
      format.html { redirect_to regiones_mapas_url }
      format.json { head :no_content }
    end
  end

  # Devuelve varias regiones o una región si es una hoja
  def dame_region
    # Para la paginacion
    pagina = params[:pagina] ||= 1
    pagina = pagina.to_i
    por_pagina = 15
    offset = por_pagina*(pagina-1)

    if params[:id].present?
      begin
        set_region_mapa

        if @region_mapa.has_children?
          @region_mapa = @region_mapa.children
        end
      rescue
        error = true
      end

    else  # La region a mostrar si da clic en alguna pestaña
      if params[:tipo_region].present?
        @region_mapa = RegionMapa.where(tipo_region: params[:tipo_region])
      else
        @region_mapa = RegionMapa.where(tipo_region: 'estado')
      end
    end

    if @region_mapa
      @region_mapa = @region_mapa.offset(offset).limit(por_pagina).order(nombre_region: :asc)
    end

    respond_to do |format|
      format.html
      format.json do
        @res = {}

        if error.blank?
          @res[:estatus] = true
          @res[:resultados] = @region_mapa
        else
          @res[:estatus] = false
          @res[:msg] = "No existe una región con el ID: #{params[:id]}"
        end

        render json: @res
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_region_mapa
    @region_mapa = RegionMapa.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def region_mapa_params
    params[:region_mapa]
  end
end
