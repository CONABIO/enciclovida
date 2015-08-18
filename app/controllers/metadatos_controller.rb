class MetadatosController < ApplicationController

  skip_before_filter :verify_authenticity_token, :set_locale, :only => :create
  before_action :authenticate_request!, :only => :create
  before_action :set_metadato, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_usuario!, :except => :create
  layout false

  # GET /metadatos
  # GET /metadatos.json
  def index
    @metadatos = Metadato.all
  end

  # GET /metadatos/1
  # GET /metadatos/1.json
  def show
  end

  # GET /metadatos/new
  def new
    @metadato = Metadato.new
  end

  # GET /metadatos/1/edit
  def edit
  end

  # POST /metadatos
  # POST /metadatos.json
  def create
    #@metadato = Metadato.new(metadato_params)
    @metadato = Metadato.find_or_create_by_path(metadato_params)

      if @metadato.save!(metadato_params)
        #format.html { redirect_to @metadato, notice: 'Metadato was successfully created.' }
        #format.json { render action: 'show', status: :created, location: @metadato }
        render inline: "<%= 'OK' %>"
      else
        #format.html { render action: 'new' }
        #format.json { render json: @metadato.errors, status: :unprocessable_entity }
        render nothing: true
      end
  end

  # PATCH/PUT /metadatos/1
  # PATCH/PUT /metadatos/1.json
  def update
    respond_to do |format|
      if @metadato.update(metadato_params)
        #format.html { redirect_to @metadato, notice: 'Metadato was successfully updated.' }
        #format.json { head :no_content }
      else
        #format.html { render action: 'edit' }
        #format.json { render json: @metadato.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /metadatos/1
  # DELETE /metadatos/1.json
  def destroy
    @metadato.destroy
    respond_to do |format|
      format.html { redirect_to metadatos_url }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_metadato
    @metadato = Metadato.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def metadato_params
    params.require(:metadato).permit(:path, :object_name, :artist, :copyright, :country_name, :province_state,
                                     :transmission_reference, :category, :supp_category, :keywords,
                                     :custom_field12, :custom_field6, :custom_field7, :custom_field13)
  end

  def authenticate_request!
    #return nil unless CONFIG.fotos_ip.include?(request.remote_ip)
  end
end

