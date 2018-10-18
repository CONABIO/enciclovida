class Observacionescarac < Ficha

	# Asignación de tabla
	self.table_name = 'observacionescarac'

	self.primary_keys = :especieId,  :idpregunta

end
