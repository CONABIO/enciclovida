class Relmetadatosasociado < Ficha
	#establish_connection(:fichasespecies)
 	# Asignación de tabla
	self.table_name = 'relmetadatosasociado'

	self.primary_keys = :asociadoId,  :metadatosId

	belongs_to :asociado, :class_name => 'Asociado', :foreign_key => 'asociadoId'
	belongs_to :metadatos, :class_name => 'Metadatos', :foreign_key => 'metadatosId'

end
