class Fichas::Conservacion < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.conservacion"
	self.primary_keys = :conservacionId,  :especieId

	belongs_to :cat_gruposEspecies, :class_name => 'Fichas::Cat_Gruposespecies', :foreign_key => 'Id'
	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId'

	TIPO_VEDA = [
			'Permanente'.to_sym,
			'Permanente solo para pesca deportiva'.to_sym,
			'Temporal fija'.to_sym
	]

	TIPO_APROVECHAMIENTO = [
		'Forestal - '.to_sym,
		'Aprovechamiento forestal maderable'.to_sym,
		'Aprovechamiento forestal no maderable'.to_sym,
		'Uso doméstico forestal'.to_sym,
		'UMA y PIMVS -'.to_sym,
		'Extractivo - Caza deportiva'.to_sym,
		'Extractivo - Aprovechamiento forestal'.to_sym,
		'Extractivo - Pesca'.to_sym,
		'Extractivo - Colecta científica y con fines de enseñanza'.to_sym,
		'Extractivo - Aprovechamiento en ritos y ceremonias tradicionales'.to_sym,
		'Extractivo - Subsistencia'.to_sym,
		'Extractivo - Extractivo con fines de reproducción'.to_sym,
		'No extractivo'.to_sym,
		'Mixto'.to_sym
	]

	TIPO_CAPTURA = [
		'Selectiva'.to_sym,
		'No selectiva'.to_sym
	]
end
