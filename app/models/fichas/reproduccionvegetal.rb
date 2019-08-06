class Fichas::Reproduccionvegetal < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.reproduccionvegetal"
	self.primary_key = 'reproduccionVegetalId'

	belongs_to :cat_caracfruto, :class_name => 'Fichas::Cat_Caracfruto', :foreign_key => 'IdFruto'
	has_one :historiaNatural, class_name: 'Fichas::Historianatural', :foreign_key => 'reproduccionVegetalId'

	has_many :t_arregloespacialflores, through: :historiaNatural
	has_many :t_arregloespacialindividuos, through: :historiaNatural
	has_many :t_arregloespacialpoblaciones, through: :historiaNatural
	has_many :t_vectorespolinizacion, through: :historiaNatural
	has_many :t_agentespolinizacion, through: :historiaNatural

	accepts_nested_attributes_for :t_arregloespacialflores, allow_destroy: true
	accepts_nested_attributes_for :t_arregloespacialindividuos, allow_destroy: true
	accepts_nested_attributes_for :t_arregloespacialpoblaciones, allow_destroy: true
	accepts_nested_attributes_for :t_vectorespolinizacion, allow_destroy: true
	accepts_nested_attributes_for :t_agentespolinizacion, allow_destroy: true

	AISLAMIENTO_ORGANOS_REPROD = [
		'Dicogamia'.to_sym,
		'Protandria'.to_sym,
		'Protoginia'.to_sym,
		'Hercogamia'.to_sym
	]

	SISTEMAS_REPROD_ASEXUALES = [
		'Multiplicación vegetativa'.to_sym,
		'Esporulación'.to_sym,
		'Apomixis'.to_sym
	]

	TIPO_FECUNDACION = [
		'Alogamia'.to_sym,
		'Autogamia'.to_sym,
		'Cleistogamia'.to_sym
	]

	FLORACION_HORARIO_APERTURA = [
		'Diurno'.to_sym,
		'Crepuscular'.to_sym,
		'Nocturno'.to_sym
	]

	EVENTOS_REPROD = [
		'Iteróparo'.to_sym,
		'Semélparo'.to_sym
	]

end
