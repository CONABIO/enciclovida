class EstadoF < Ficha
	#establish_connection(:fichasespecies)
 	# Asignación de tabla
	self.table_name = 'estado'

	self.primary_key = 'estadoId'

	has_many :relDistribucionesEstados, class_name: 'Reldistribucionestado'
end
