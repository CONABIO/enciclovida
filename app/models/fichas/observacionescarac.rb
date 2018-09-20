class Observacionescarac < Ficha
	#establish_connection(:fichasespecies)
 	# Asignación de tabla
	self.table_name = 'observacionescarac'

	self.primary_keys = :especieId,  :idpregunta

end
