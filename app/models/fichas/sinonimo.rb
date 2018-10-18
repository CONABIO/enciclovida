class Sinonimo < Ficha

	# Asignación de tabla
	self.table_name = 'sinonimo'

	self.primary_keys = :especieId,  :nombreSimple,  :autoridad

	belongs_to :taxon, :class_name => 'Taxon', :foreign_key => 'especieId'

end
