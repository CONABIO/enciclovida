class Conservacion < Ficha

	# Asignación de tabla
	self.table_name = 'conservacion'

	self.primary_keys = :conservacionId,  :especieId

	belongs_to :cat_gruposEspecies, :class_name => 'Cat_Gruposespecies', :foreign_key => 'Id'
	belongs_to :taxon, :class_name => 'Taxon', :foreign_key => 'especieId'
end
