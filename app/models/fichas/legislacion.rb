class Legislacion < Ficha

	#establish_connection(:fichasespecies)

 	# Asignación de tabla
	self.table_name = 'legislacion'

	self.primary_keys = :legislacionId,  :especieId

	belongs_to :taxon, :class_name => 'Taxon', :foreign_key => 'especieId'
end
