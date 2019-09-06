class Fichas::Historianatural < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.historianatural"
	self.primary_key = :historiaNaturalId#, :especieId

	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId'

	has_one :cat_estrategiaTrofica, :class_name => 'Fichas::Cat_Estrategiatrofica', :foreign_key => 'IdEstrategia'
	belongs_to :reproduccionAnimal, :class_name => 'Fichas::Reproduccionanimal', :foreign_key => 'reproduccionAnimalId', optional: true
	belongs_to :reproduccionVegetal, :class_name => 'Fichas::Reproduccionvegetal', :foreign_key => 'reproduccionVegetalId', optional: true

	has_many :relHistoriasNaturalesPais, class_name: 'Fichas::Relhistorianaturalpais', :foreign_key => 'historiaNaturalId'
	has_many :relHistoriasNaturalesUsos, class_name: 'Fichas::Relhistorianaturalusos', :foreign_key => 'historiaNaturalId'
  has_many :pais_importacion, class_name: 'Fichas::Pais', through: :relHistoriasNaturalesPais
	has_many :culturaUsos, class_name: 'Fichas::Culturausos', through: :relHistoriasNaturalesUsos

	# - - - - - -   Preguntas de observaciones en la tabla Observacionescarac ( INFORMACIÓN ADICIONAL EN SU MAYORÍA ) - - - - - - #
	# De biología
	has_many :infoalimenta,-> {where('observacionescarac.idpregunta = ?', 9 )}, class_name: 'Fichas::Observacionescarac', primary_key: :especieId, foreign_key: :especieId, inverse_of: :taxon
	has_many :infoaddforrajeo,-> {where('observacionescarac.idpregunta = ?', 8 )}, class_name: 'Fichas::Observacionescarac', primary_key: :especieId, foreign_key: :especieId, inverse_of: :taxon
	has_many :infoaddhabito,-> {where('observacionescarac.idpregunta = ?', 12 )}, class_name: 'Fichas::Observacionescarac', primary_key: :especieId, foreign_key: :especieId, inverse_of: :taxon
	has_many :infodisp,-> {where('observacionescarac.idpregunta = ?', 15 )}, class_name: 'Fichas::Observacionescarac', primary_key: :especieId, foreign_key: :especieId, inverse_of: :taxon
	has_many :infostruct,-> {where('observacionescarac.idpregunta = ?', 16 )}, class_name: 'Fichas::Observacionescarac', primary_key: :especieId, foreign_key: :especieId, inverse_of: :taxon
	# De rep. animal
	has_many :infosistaparea,-> {where('observacionescarac.idpregunta = ?', 13 )}, class_name: 'Fichas::Observacionescarac', primary_key: :especieId, foreign_key: :especieId, inverse_of: :taxon
	has_many :infocrianza,-> {where('observacionescarac.idpregunta = ?', 14 )}, class_name: 'Fichas::Observacionescarac', primary_key: :especieId, foreign_key: :especieId, inverse_of: :taxon
	# De rep. vegetal
	has_many :infoarresp,-> {where('observacionescarac.idpregunta = ?', 46 )}, class_name: 'Fichas::Observacionescarac', primary_key: :especieId, foreign_key: :especieId, inverse_of: :taxon
	has_many :infoAP,-> {where('observacionescarac.idpregunta = ?', 48 )}, class_name: 'Fichas::Observacionescarac', primary_key: :especieId, foreign_key: :especieId, inverse_of: :taxon

	accepts_nested_attributes_for :infoAP, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :infoarresp, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :infoalimenta, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :infoaddforrajeo, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :infoaddhabito, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :infosistaparea, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :infocrianza, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :infodisp, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :infostruct, allow_destroy: true, reject_if: :all_blank
	
	# Acceso a las opciones de catálogo
	accepts_nested_attributes_for :culturaUsos, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :reproduccionAnimal, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :reproduccionVegetal, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :cat_estrategiaTrofica, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :pais_importacion, allow_destroy: true, reject_if: :all_blank


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
