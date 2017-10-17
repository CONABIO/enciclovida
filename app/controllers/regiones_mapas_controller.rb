class RegionesMapasController < ApplicationController
  skip_before_filter :verify_authenticity_token, :set_locale
  before_action :set_region_mapa, only: [:show, :edit, :update, :destroy]
  layout false, :only => [:dame_tipo_region, :dame_ancestry]

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

  # Devuelve varias regiones
  def dame_tipo_region
    # Para la paginacion
    pagina = params[:pagina] ||= 1
    pagina = pagina.to_i
    por_pagina = 15
    offset = por_pagina*(pagina-1)
    region_mapa = {}

    begin
      region_mapa[:estatus] = true
      res = params[:tipo_region].camelize.constantize.campos_min.offset(offset).limit(por_pagina)
      region_mapa[:resultados] = res.map do |r|
        regiones = r.nombre_region.split(',')
        estado = t("estados.#{regiones.last.estandariza}", default: regiones.last)
        nombre_region = (regiones[0..-2].push(estado)).join(', ')

         {region_id: r.region_id.to_s.rjust(2,'0'), nombre_region: nombre_region, parent_id: r.try(:parent_id)}
      end
    rescue
      region_mapa[:estatus] = false
      region_mapa[:msg] = "No existe nada con el tipo de region: #{params[:tipo_region]}"
    end

    respond_to do |format|
      format.html
      format.json do
        render json: region_mapa
      end
    end
  end

  # Devuelve el geo_id e los ancestros para poder consultar el servicio de abraham
  def dame_ancestry
    resp = if params[:region_id].present?
             begin
               region = RegionMapa.find(params[:region_id])
             rescue
               region = RegionMapa.none
             end

             if region.present?
               regiones = {}

               region.path.each do |r|

                 geo_id = r.tipo_region == 'municipio' ? r.geo_id.to_s.rjust(3,'0') : r.geo_id.to_s.rjust(2,'0')
                 regiones[r.tipo_region] = geo_id
               end

               {estatus: true, regiones: regiones, tipo_region: region.tipo_region}
             else
               {estatus: false, msg: "No hay regiones con region_id = #{params[:region_id]}"}
             end
           else
             {estatus: false, msg: 'El atributo "region_id" no esta presente'}
           end

    render json: resp
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
