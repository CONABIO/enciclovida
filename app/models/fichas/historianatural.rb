class Fichas::Historianatural < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.historianatural"
	self.primary_keys = :historiaNaturalId,  :especieId

	belongs_to :cat_estrategiaTrofica, :class_name => 'Fichas::Cat_Estrategiatrofica', :foreign_key => 'IdEstrategia'
	belongs_to :reproduccionAnimal, :class_name => 'Fichas::Reproduccionanimal', :foreign_key => 'reproduccionAnimalId'
	belongs_to :reproduccionVegetal, :class_name => 'Fichas::Reproduccionvegetal', :foreign_key => 'reproduccionVegetalId'
	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId'

	has_many :relHistoriasNaturalesPais, class_name: 'Fichas::Relhistorianaturalpais'
	has_many :relHistoriasNaturalesUsos, class_name: 'Fichas::Relhistorianaturalusos', :foreign_key => 'historiaNaturalId'

	has_many :culturaUsos, class_name: 'Fichas::Culturausos', through: :relHistoriasNaturalesUsos

	accepts_nested_attributes_for :culturaUsos, allow_destroy: true
	accepts_nested_attributes_for :reproduccionAnimal, allow_destroy: true
	accepts_nested_attributes_for :reproduccionVegetal, allow_destroy: true

	FUNCIONES_ECOLOGICAS = [
    'Productores'.to_sym,
    'Depredador'.to_sym,
    'Depredador tope'.to_sym,
    'Descomponedor'.to_sym,
    'Dispersor'.to_sym,
    'Polinizador'.to_sym,
    'Fijadores de carbono'.to_sym,
    'Fijadores de nitrógeno'.to_sym,
    'Otros'.to_sym
	]

	HABITO_PLANTAS = [
    'Árboles'.to_sym,
    'Arbustos'.to_sym,
    'Subarbustos'.to_sym,
    'Hierbas'.to_sym,
    'Lianas'.to_sym,
    'Suculentas'.to_sym,
    'En forma de almohada'.to_sym,
    'Epífitas'.to_sym,
    'Arrosetadas'.to_sym,
    'Trepadoras'.to_sym,
    'Rastreras'.to_sym,
    'Parásitas'.to_sym,
    'Arborescente'.to_sym
	]

	ALIMENTACION = [
		'Autótrofos'.to_sym,
		'Heterótrofos'.to_sym,
		'Herbívoros(Polinívoros)'.to_sym,
		'Herbívoros(Nectarívoros)'.to_sym,
		'Herbívoros(Granívoros)'.to_sym,
		'Herbívoros(Frugívoros)'.to_sym,
		'Herbívoros(Folívoros)'.to_sym,
		'Herbívoros(Rizófagos)'.to_sym,
		'Carnívoros(Hematófagos)'.to_sym,
		'Carnívoros(Carroñeros)'.to_sym,
		'Carnívoros(Insectívoros)'.to_sym,
		'Carnívoros(Piscívoros)'.to_sym,
		'Carnívoros(Oófagos)'.to_sym,
		'Omnívoros'.to_sym,
		'Detritívoros'.to_sym,
		'Saprófagos'.to_sym,
		'Carnívoros'.to_sym
	]

	FORRAJEO = [
		'Acuático'.to_sym,
		'Arbóreas'.to_sym,
		'Buceador'.to_sym,
		'Carroñero'.to_sym,
		'Cazador aéreo (bajo el dosel)'.to_sym,
		'Cazador aéreo (sobre el dosel)'.to_sym,
		'Cazador terrestre'.to_sym,
		'Forrajeo en el follaje'.to_sym,
		'Forrajeo en el suelo'.to_sym,
		'Forrajeo en la corteza de los árboles'.to_sym
	]

	ESTATUS_MIGRATORIO = [
		'Residente'.to_sym,
		'Migratorio de invierno'.to_sym,
		'Transitorio'.to_sym,
		'Accidental'.to_sym,
		'Otro'.to_sym
	]

	TIPO_MIGRACION = [
		'Latitudinal'.to_sym,
		'Longitudinal'.to_sym,
		'Altitudinal'.to_sym,
		'Vertical en columnas de agua'.to_sym,
		'Migrante local'.to_sym
	]

	HABITO = [
		'Arborícola'.to_sym,
		'Acuático'.to_sym,
		'Cursorial'.to_sym,
		'Epífito'.to_sym,
		'Palustre'.to_sym,
		'Rupícola'.to_sym,
		'Saltatorial'.to_sym,
		'Semiarborícola'.to_sym,
		'Semiacuático'.to_sym,
		'Terrestre'.to_sym,
		'Trepador'.to_sym,
		'Volador'.to_sym,
		'Otro'.to_sym
	]

	PERIODO_ACTIVIDAD = [
		'Diurno'.to_sym,
		'Nocturno'.to_sym,
		'Crepuscular'.to_sym
	]

	MECANISMO_DEFENSA = [
		'Defensa química'.to_sym,
		'Alelopatía'.to_sym,
		'Coloración'.to_sym,
		'Defensa química'.to_sym,
		'Espinas'.to_sym,
		'Mimetismo'.to_sym,
		'Veneno'.to_sym
	]

  TIPO_REPRODUCCION = [
    'animal'.to_sym,
    'veget'.to_sym
  ]


	def get_info_reproduccion
		if self.tipoReproduccion == 'animal'
			return self.reproduccionAnimal
		else
			return self.reproduccionVegetal
		end
	end

end
