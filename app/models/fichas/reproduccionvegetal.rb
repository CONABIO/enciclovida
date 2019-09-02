class Fichas::Reproduccionvegetal < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.reproduccionvegetal"
	self.primary_key = 'reproduccionVegetalId'

	has_one :cat_caracfruto, :class_name => 'Fichas::Cat_Caracfruto', :foreign_key => 'IdFruto'
	has_one :historiaNatural, class_name: 'Fichas::Historianatural', :foreign_key => 'reproduccionVegetalId'

	# De rep. vegetal
	has_many :infoarresp, through: :historiaNatural
	has_many :infoAP, through: :historiaNatural

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
