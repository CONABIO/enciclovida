class Productocomercio < Ficha
	#establish_connection(:fichasespecies)
 	# Asignación de tabla
	self.table_name = 'productocomercio'

	self.primary_keys = :especieId,  :tipoproducto,  :nacionalinternacional

	belongs_to :taxon, :class_name => 'Taxon', :foreign_key => 'especieId'
end
