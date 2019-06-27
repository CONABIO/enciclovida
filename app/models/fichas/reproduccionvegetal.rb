class Fichas::Reproduccionvegetal < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.reproduccionvegetal"
	self.primary_key = 'reproduccionVegetalId'

	belongs_to :cat_caracfruto, :class_name => 'Fichas::Cat_Caracfruto', :foreign_key => 'IdFruto'
	has_one :historiaNatural, class_name: 'Fichas::Historianatural'

	FLORES = [
		'Hermafroditas'.to_sym,
		'Unisexuales'.to_sym
	]

	INDIVIDUOS = [
		'Monoicas'.to_sym,
		'Dioicas'.to_sym,
		'Andromonoicas'.to_sym,
		'Ginomonoicas'.to_sym,
		'Subandroicas'.to_sym,
		'Subginoicas'.to_sym,
		'Polígamas'.to_sym
	]

	POBLACIONES = [
		'Hermafroditas'.to_sym,
		'Monoicas'.to_sym,
		'Dioicas'.to_sym,
		'Ginodioicas'.to_sym,
		'Androdiocas'.to_sym,
		'Trioicas'.to_sym
	]

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

	TIPO_POLINIZACION = [
		'Polinización cruzada'.to_sym,
		'Autopolinización'.to_sym
	]

	VECTORES_POLINIZACION = [
		'Viento'.to_sym,
		'Agua'.to_sym,
		'Gravedad'.to_sym,
		'Animales'.to_sym
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
