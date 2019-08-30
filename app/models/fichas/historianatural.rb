class Fichas::Historianatural < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.historianatural"
	self.primary_key = :historiaNaturalId#, :especieId

	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId'

	has_one :cat_estrategiaTrofica, :class_name => 'Fichas::Cat_Estrategiatrofica', :foreign_key => 'IdEstrategia'
	has_one :reproduccionAnimal, :class_name => 'Fichas::Reproduccionanimal', :foreign_key => 'reproduccionAnimalId'
	has_one :reproduccionVegetal, :class_name => 'Fichas::Reproduccionvegetal', :foreign_key => 'reproduccionVegetalId'

	has_many :relHistoriasNaturalesPais, class_name: 'Fichas::Relhistorianaturalpais', :foreign_key => 'historiaNaturalId'
	has_many :relHistoriasNaturalesUsos, class_name: 'Fichas::Relhistorianaturalusos', :foreign_key => 'historiaNaturalId'
  has_many :pais_importacion, class_name: 'Fichas::Pais', through: :relHistoriasNaturalesPais
	has_many :culturaUsos, class_name: 'Fichas::Culturausos', through: :relHistoriasNaturalesUsos
	
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
