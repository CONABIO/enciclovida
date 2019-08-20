class Fichas::Historianatural < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.historianatural"
	self.primary_keys = :historiaNaturalId,  :especieId

	belongs_to :cat_estrategiaTrofica, :class_name => 'Fichas::Cat_Estrategiatrofica', :foreign_key => 'IdEstrategia'
	belongs_to :reproduccionAnimal, :class_name => 'Fichas::Reproduccionanimal', :foreign_key => 'reproduccionAnimalId'
	belongs_to :reproduccionVegetal, :class_name => 'Fichas::Reproduccionvegetal', :foreign_key => 'reproduccionVegetalId'
	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId'

	has_many :relHistoriasNaturalesPais, class_name: 'Fichas::Relhistorianaturalpais', :foreign_key => 'historiaNaturalId'
	has_many :relHistoriasNaturalesUsos, class_name: 'Fichas::Relhistorianaturalusos', :foreign_key => 'historiaNaturalId'
	has_many :caracteristicasEspecies, :class_name => 'Fichas::Caracteristicasespecie', :foreign_key => 'especieId', :primary_key => :especieId

  has_many :pais_importacion, class_name: 'Fichas::Pais', through: :relHistoriasNaturalesPais
	has_many :culturaUsos, class_name: 'Fichas::Culturausos', through: :relHistoriasNaturalesUsos

	# Cat_preguntas: CONSIDERANDO QUE EN ESTA TABLA EDSTÂN TODOS LOS CATALOGOS JUNTOS
	has_many :t_habitoPlantas, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
	has_many :t_alimentacion, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
	has_many :t_forrajeo, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
	has_many :t_migracion, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
	has_many :t_tipo_migracion, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
	has_many :t_habito, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
	has_many :t_tipodispersion, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
	has_many :t_structdisp, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
	has_many :t_dispersionsei, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
  has_many :t_comnalsel, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
  has_many :t_proposito_com, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
  has_many :t_comintersel, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
  has_many :t_proposito_com_int, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies

  # Para T ANIMAL
	has_many :t_sistapareamiento, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
	has_many :t_sitioanidacion, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies

  # Para T VEGETAL
	has_many :t_arregloespacialflores, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
	has_many :t_arregloespacialindividuos, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
	has_many :t_arregloespacialpoblaciones, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
	has_many :t_vectorespolinizacion, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
	has_many :t_agentespolinizacion, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies


	# Acceso a las opciones de catálogo
	accepts_nested_attributes_for :culturaUsos, allow_destroy: true
	accepts_nested_attributes_for :reproduccionAnimal, allow_destroy: true
	accepts_nested_attributes_for :reproduccionVegetal, allow_destroy: true
	accepts_nested_attributes_for :cat_estrategiaTrofica, allow_destroy: true
	accepts_nested_attributes_for :pais_importacion, allow_destroy: true
	accepts_nested_attributes_for :culturaUsos, allow_destroy: true

	# Acceso a las opciones multiples del catálogo grande:
	accepts_nested_attributes_for :t_habitoPlantas, allow_destroy: true
	accepts_nested_attributes_for :t_alimentacion, allow_destroy: true
	accepts_nested_attributes_for :t_forrajeo, allow_destroy: true
	accepts_nested_attributes_for :t_migracion, allow_destroy: true
	accepts_nested_attributes_for :t_tipo_migracion, allow_destroy: true
	accepts_nested_attributes_for :t_habito, allow_destroy: true
	accepts_nested_attributes_for :t_tipodispersion, allow_destroy: true
	accepts_nested_attributes_for :t_structdisp, allow_destroy: true
	accepts_nested_attributes_for :t_dispersionsei, allow_destroy: true
	accepts_nested_attributes_for :t_comnalsel, allow_destroy: true
	accepts_nested_attributes_for :t_proposito_com, allow_destroy: true
	accepts_nested_attributes_for :t_comintersel, allow_destroy: true
	accepts_nested_attributes_for :t_proposito_com_int, allow_destroy: true

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
