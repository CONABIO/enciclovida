class Invasividad < Ficha
	#establish_connection(:fichasespecies)
 	# Asignación de tabla
	self.table_name = 'invasividad'

	self.primary_keys = :invaisvidadId,  :especieId

end
