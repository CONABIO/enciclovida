class Fichas::Conservacion < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.conservacion"
	self.primary_keys = :conservacionId,  :especieId

	belongs_to :cat_gruposEspecies, :class_name => 'Fichas::Cat_Gruposespecies', :foreign_key => 'Id'
	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId'

  has_many :caracteristicasEspecies, :class_name => 'Fichas::Caracteristicasespecie', :foreign_key => 'especieId', :primary_key => :especieId

	# Cat_preguntas: CONSIDERANDO QUE EN ESTA TABLA EDSTÂN TODOS LOS CATALOGOS JUNTOS
	has_many :t_esquemamanejo, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
	has_many :t_tipopesca, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
	has_many :t_regioncaptura, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies

	accepts_nested_attributes_for :t_esquemamanejo, allow_destroy: true
	accepts_nested_attributes_for :t_tipopesca, allow_destroy: true
	accepts_nested_attributes_for :t_regioncaptura, allow_destroy: true


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
