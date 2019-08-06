class Fichas::TaxaController < Fichas::FichasController
  before_action :set_taxon, only: [:show, :edit, :update, :destroy]

  # GET /taxa
  # GET /taxa.json
  def index
    @taxa = Fichas::Taxon.all
  end

  # GET /taxa/1
  # GET /taxa/1.json
  def show
  end

  # GET /taxa/new
  def new
    @form_params = { url: '/fichas/taxa', method: 'post' }
    @taxon = Fichas::Taxon.new
  end

  # GET /taxa/1/edit
  def edit
    @form_params = { url: "/fichas/taxa/#{@taxon.IdCAT}", method: 'put' }
  end


  # POST /taxa
  # POST /taxa.json
  def create
    @taxon = Fichas::Taxon.new(taxon_params)

    respond_to do |format|
      if @taxon.save
        format.html { redirect_to @taxon, notice: 'Taxon was successfully created.' }
        format.json { render :show, status: :created, location: @taxon }
      else
        format.html { render :new }
        format.json { render json: @taxon.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /taxa/1
  # PATCH/PUT /taxa/1.json
  def update
    respond_to do |format|
      if @taxon.update(taxon_params)
        format.html { redirect_to fichas_front_path(@taxon.IdCAT), notice: 'Taxon was successfully updated.' }
        format.json { render :show, status: :ok, location: @taxon }
      else
        format.html { render :edit }
        format.json { render json: @taxon.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /taxa/1
  # DELETE /taxa/1.json
  def destroy
    @taxon.destroy
    respond_to do |format|
      format.html { redirect_to taxa_url, notice: 'Taxon was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_taxon
      begin
        @taxon = Fichas::Taxon.where(IdCat: params[:id]).first
      rescue
        render :_error and return
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def taxon_params
      params.require(:fichas_taxon).permit(
          # Parámetros desde taxón:
          :resumenEspecie, :descEspecie, :largoinicialhembras, :largofinalhembras, :edadinicialhembras, :edadfinalhembras, :tiempoedadhembra, :pesoinicialhembras, :pesofinalhembras, :especiesSmilares, :origen, :descripcionOrigen, :presencia, :adicinalPresencia, :invasora, :adicionalInvasora, :id, :_destroy,

          legislaciones_attributes: [:legislacionId, :especieId, :nombreLegislacion, :estatusLegalProteccion, :infoAdicional, :id, :_destroy],

          habitats_attributes: [:ecorregion_ids, :id, :_destroy],

          distribuciones_attributes: [
              :pai_ids,
              :distribucion_historica,
              :estado_ids,
              :infoadicionalmexedo,
              :municipio_ids,
              :infoAdicionalMun,
              :historicaPotencial,
              :alcanceDistribucion,
              :infoAdicionalAlcance,
              :pais_inv_ids,
              :comoExoticaMundial,
              :pais_inv2_ids,
              :distribucionOriginal,
              :tipoDistribucion,
              :infoAdicionalTipo,
              :id,
              :_destroy],
              distribucion_historica_attributes: [:especieId, :regLoc, :anioinicial, :mesinicial, :aniofinal, :mesfinal, :id, :_destroy ]
      )
    end
end



=begin
habitats_attributes: {
    info_ecorregiones_attributes:
        [:habitatId, :especieId, :idpregunta, :infoadicional, :_destroy]
}



habitats_attributes
:temperaturainicial, :temperaturafinal,
 :ecosistema_ids, :vegetacion_ids, :tipoVegetacion,


:estadoHabitat,
:addinfoestadoHabitat,
:t_habitatAntropico_ids,
:habitatAgropecuario,
:zonaUrbana,
:t_tipoVegetacionSecundarium_ids,
:intervaloaltitudinalinicial,
:intervaloaltitudinalfinal,
:infoAddintervaloaltitudinal,
:t_clima_ids,
:climaAdicional,

:infoaddtemperatura,
:temperaturainicialexo,
:temperaturafinalexo,
:infoaddtemperaturaexo,
:precipitacioninicial,
:precipitacionfinal,
:infoaddprecipitacion,
:precipitacioninicialexo,
:precipitacionfinalexo,
:infoaddprecipitacionexo,
:humedadinicial,
:humedadfinal,
:infoaddhumedad,
:t_suelo_ids,
:descripcionSuelo,
:t_geoforma_ids,
:descripcionGeoforma,
:t_ecorregionMarinaN1_ids,
:t_zonaVida_ids,
:biotipos,
:vegetacion_acuatica_ids,
:salinidadinicial,
:salinidadfinal,
:unidadsalinidad,
:oxigenoinicial,
:oxigenofinal,
:phinicial,
:phfinal,
:temeperaturainicial,
:temeperaturafinal,
:corrientes,
:infoaddcaracagua,
:intervaloaltitudinalacuainicial,
:intervaloaltitudinalacuafinal,
:infoAddintervaloaltitudinalacua,
:interbatimetricoinicial,
:interbatimetricofinal,
:infoaddinterbatimetrico,
:amplitudmareasinicial,
:amplitudmareasfinal,
:infoaddamplitudmareas,
:tipoVegetacionexo,
:uso,







endemicas_attributes
endemicaA
infoAdicionalEndemica
id



historiaNatural_attributes
t_habitoPlanta_ids
t_alimentacion_ids
descripcionAlimentacion
estrategiaTrofica
descripcionEstrofica
t_forrajeo_ids
conducta
t_migracion_ids
t_tipo_migracion_ids
t_habito_ids
tipopHabito
infoaddperiodoactividad
infoaddhibernacion
infoaddterritorialidad
ambitoHogareno
mecanismosDefensa
infoaddmecdefensa
t_tipodispersion_ids
descTipoDispersion
t_structdisp_ids
descEstDispersora
distanciadispercioninicial
distanciadispercionfinal
variabilidadGenetica
marcadorGenetico
secuencias
mexbol
ImportanciaBiologica
funcionEcologica
importanciaEconomica
t_comnalsel_ids
t_proposito_com_ids
t_comintersel_ids
t_proposito_com_int_ids
pais_importacion_ids
comercioIlicitoNal
comercioIlicitoInter
descComIlicito
culturaUso_ids
descUsos


reproduccionAnimal_attributes
descripcion
additionalInfoDimorfiasmo
coloracion
ornamentacion
t_sistapareamiento_ids
descripcionSistema
noEventos
descripcionNoEventos
tiempoentrecriasinicial
tiempoentrecriasfinal
tipoFecundacion
descripcionTipoFec
edadPrimeraRepro
duracionVidaRepro
frecuenciaApareamineto
t_sitioanidacion_ids
noHuevosCrias
cuidadoParentalPor
desCuidadoParental
tiempoCuidadoParental


reproduccionVegetal_attributes
descripcion
t_arregloespacialflore_ids
t_arregloespacialindividuo_ids
t_arregloespacialpoblacione_ids
aislamientoOrganos
descAislaOrganos
sistReproAsexuales
DescsistReproAsexuales
fecuandacion
descFecundacion
t_vectorespolinizacion_ids
t_agentespolinizacion_ids
aperturaFlor
descApertura
tiempoFloracion
addinfolongevidadflor
mesInicio
mesFinal
addinfotiempoflora
cantidadnectarinicial
cantidadnectarfinal
addinfocantidadnectar
cantidadpolen
mesInicialFructi
mesFinalFructi
addinfotiempofructi
nofrutosinicial
nofrutosfinal
caracFruto
descCaracFruto
noEventos
descNoEventos
nosemillasinicial
nosemillasfinal
tamanioSemilla
caracToxica
germinacioninicial
germinacionfinal
infoaddgerminacion
plantulasinicial
plantulasfinal
infoaddplantulas
arregloEspacial
descripcionArregloespacial
agentesPolinizacion
descAgentesPol



demografiaAmenazas_attributes

conservacion_attributes
=end