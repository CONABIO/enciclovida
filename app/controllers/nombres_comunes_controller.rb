class NombresComunesController < ApplicationController
  before_action :set_nombr_comune, only: [:show, :edit, :update, :destroy]

  # GET /nombres_comunes
  # GET /nombres_comunes.json
  def index
    @nombres_comunes = NombreComun.limit(params['limit'] ||= 100).offset(params['offset'] ||= 0)
  end

  # GET /nombres_comunes/1
  # GET /nombres_comunes/1.json
  def show
  end

  # GET /nombres_comunes/new
  def new
    @nombr_comune = NombreComun.new
  end

  # GET /nombres_comunes/1/edit
  def edit
  end

  # POST /nombres_comunes
  # POST /nombres_comunes.json
  def create
    @nombr_comune = NombreComun.new(nombr_comune_params)

    respond_to do |format|
      if @nombr_comune.save
        format.html { redirect_to @nombr_comune, notice: 'Nombre comun was successfully created.' }
        format.json { render action: 'show', status: :created, location: @nombr_comune }
      else
        format.html { render action: 'new' }
        format.json { render json: @nombr_comune.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /nombres_comunes/1
  # PATCH/PUT /nombres_comunes/1.json
  def update
    respond_to do |format|
      if @nombr_comune.update(nombr_comune_params)
        format.html { redirect_to @nombr_comune, notice: 'Nombre comun was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @nombr_comune.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /nombres_comunes/1
  # DELETE /nombres_comunes/1.json
  def destroy
    @nombr_comune.destroy
    respond_to do |format|
      format.html { redirect_to nombres_comunes_url }
      format.json { head :no_content }
    end
  end

  def buscar
    referencia = NombreComun.all.order('nombre_comun ASC')
    @q = params[:q].to_s
    if @q.present?
      nombresComunes = referencia.select(:nombre_comun).where("lower_unaccent(nombre_comun) LIKE lower_unaccent('%#{@q}%')")
    end
    @nombresComunes=''
    #@nombresComunes.page(params[:page])
    respond_to do |format|
      format.html {@nombresComunes=nombresComunes.first.nombre_comun}
      format.json do
        #haml_pretty do
        nombresComunes.each do |nc|
          #nc.html=view_context.render_in_format(:html, :partial => 'escogio', :object => nc).gsub(/\n/, '')
          #@users[i].html = view_context.render_in_format(:html, :partial => "users/chooser", :object => user).gsub(/\n/, '')
          #@nombresComunes+=nc.nombre_comun
          #end
        end
        render :json => nombresComunes.first.nombre_comun.to_json
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_nombr_comune
    begin
      @nombr_comune = NombreComun.find(params[:id])
    rescue
      @nombr_comune={:nombre_comun => nil}
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def nombr_comune_params
    params[:nombr_comune]
  end
end
