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
      p = params.require(:fichas_taxon).permit(
          # Parámetros desde taxón:
          :resumenEspecie, :descEspecie, :largoinicialhembras, :largofinalhembras, :edadinicialhembras, :edadfinalhembras, :tiempoedadhembra, :pesoinicialhembras, :pesofinalhembras, :especiesSmilares, :origen, :descripcionOrigen, :presencia, :adicinalPresencia, :invasora, :adicionalInvasora, :id, :_destroy,

          legislaciones_attributes: [:legislacionId, :especieId, :nombreLegislacion, :estatusLegalProteccion, :infoAdicional, :id, :_destroy],

          habitats_attributes: [
              { ecorregion_ids: [] },
              :tipoAmbiente,
              :id,
              :_destroy
          ],

          t_clima_ids: [],

          ambi_info_ecorregiones_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          ambi_especies_asociadas_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          ambi_vegetacion_esp_mundo_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          ambi_info_clima_exotico_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],

          distribuciones_attributes: [
              :pai_ids,
              :estado_ids,
              :pais_inv_ids,
              :pais_inv2_ids,
              :municipio_ids,
              :distribucion_historica,
              :infoadicionalmexedo,
              :infoAdicionalMun,
              :historicaPotencial,
              :alcanceDistribucion,
              :infoAdicionalAlcance,
              :comoExoticaMundial,
              :distribucionOriginal,
              :tipoDistribucion,
              :infoAdicionalTipo,
              :id,
              :_destroy
          ],

          distribucion_historica_attributes: [
              :especieId,
              :regLoc,
              :anioinicial,
              :mesinicial,
              :aniofinal,
              :mesfinal,
              :id,
              :_destroy
          ]
      )

      itera_preguntas_observaciones(p)

      p
    end

  def itera_preguntas_observaciones(p)
    lista = %w(ambi_info_ecorregiones_attributes ambi_especies_asociadas_attributes ambi_vegetacion_esp_mundo_attributes ambi_info_clima_exotico_attributes)
    lista.each do |acceso|
      p[acceso].each do |k,v|
        break unless v["id"].present?
        ids = v["id"].split(' ')
        v["id"] = ids
      end
    end
    p
  end
end



=begin
habitats_attributes: {
    info_ecorregiones_attributes:
        [:habitatId, :especieId, :idpregunta, :infoadicional, :_destroy]
}



habitats_attributes: [
  :t_habitatAntropico_ids,
  :t_tipoVegetacionSecundarium_ids,
  :t_clima_ids,
  :t_suelo_ids,
  :t_geoforma_ids,
  :t_ecorregionMarinaN1_ids,
  :t_zonaVida_ids,
  :vegetacion_acuatica_ids,
  :ecosistema_ids,
  :vegetacion_ids,
  :tipoVegetacion,
  :estadoHabitat,
  :addinfoestadoHabitat,
  :habitatAgropecuario,
  :zonaUrbana,
  :temperaturainicial,
  :temperaturafinal,
  :intervaloaltitudinalinicial,
  :intervaloaltitudinalfinal,
  :infoAddintervaloaltitudinal,
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
  :descripcionSuelo,
  :descripcionGeoforma,
  :biotipos,
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
  :id,
  :_destroy
]


endemicas_attributes: [
  :endemicaA,
  :infoAdicionalEndemica,
  :id,
  :_destroy
]


historiaNatural_attributes: [
  :t_habitoPlanta_ids,
  :t_alimentacion_ids,
  :t_forrajeo_ids,
  :t_migracion_ids,
  :t_tipo_migracion_ids,
  :t_habito_ids,
  :t_tipodispersion_ids,
  :t_structdisp_ids,
  :t_comnalsel_ids,
  :t_proposito_com_ids,
  :t_comintersel_ids,
  :t_proposito_com_int_ids,
  :culturaUso_ids,
  :pais_importacion_ids,
  :descripcionAlimentacion,
  :estrategiaTrofica,
  :descripcionEstrofica,
  :conducta,
  :tipopHabito,
  :infoaddperiodoactividad,
  :infoaddhibernacion,
  :infoaddterritorialidad,
  :ambitoHogareno,
  :mecanismosDefensa,
  :infoaddmecdefensa,
  :descTipoDispersion,
  :descEstDispersora,
  :distanciadispercioninicial,
  :distanciadispercionfinal,
  :variabilidadGenetica,
  :marcadorGenetico,
  :secuencias,
  :mexbol,
  :ImportanciaBiologica,
  :funcionEcologica,
  :importanciaEconomica,
  :comercioIlicitoNal,
  :comercioIlicitoInter,
  :descComIlicito,
  :descUsos,
  :id,
  :_destroy
]


reproduccionAnimal_attributes: [
  :t_sistapareamiento_ids,
  :t_sitioanidacion_ids,
  :descripcion,
  :additionalInfoDimorfiasmo,
  :coloracion,
  :ornamentacion,
  :descripcionSistema,
  :noEventos,
  :descripcionNoEventos,
  :tiempoentrecriasinicial,
  :tiempoentrecriasfinal,
  :tipoFecundacion,
  :descripcionTipoFec,
  :edadPrimeraRepro,
  :duracionVidaRepro,
  :frecuenciaApareamineto,
  :noHuevosCrias,
  :cuidadoParentalPor,
  :desCuidadoParental,
  :tiempoCuidadoParental,
]

reproduccionVegetal_attributes: [
  :t_arregloespacialflore_ids,
  :t_arregloespacialindividuo_ids,
  :t_arregloespacialpoblacione_ids,
  :t_vectorespolinizacion_ids,
  :t_agentespolinizacion_ids,
  :descripcion,
  :aislamientoOrganos,
  :descAislaOrganos,
  :sistReproAsexuales,
  :DescsistReproAsexuales,
  :fecuandacion,
  :descFecundacion,
  :aperturaFlor,
  :descApertura,
  :tiempoFloracion,
  :addinfolongevidadflor,
  :mesInicio,
  :mesFinal,
  :addinfotiempoflora,
  :cantidadnectarinicial,
  :cantidadnectarfinal,
  :addinfocantidadnectar,
  :cantidadpolen,
  :mesInicialFructi,
  :mesFinalFructi,
  :addinfotiempofructi,
  :nofrutosinicial,
  :nofrutosfinal,
  :caracFruto,
  :descCaracFruto,
  :noEventos,
  :descNoEventos,
  :nosemillasinicial,
  :nosemillasfinal,
  :tamanioSemilla,
  :caracToxica,
  :germinacioninicial,
  :germinacionfinal,
  :infoaddgerminacion,
  :plantulasinicial,
  :plantulasfinal,
  :infoaddplantulas,
  :arregloEspacial,
  :descripcionArregloespacial,
  :agentesPolinizacion,
  :descAgentesPol
]

=end