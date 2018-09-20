class Puesto < Ficha

	# Asignación de tabla
	self.table_name = 'puesto'

	self.primary_key = 'puestoId'

	has_many :asociados, :class_name => 'Asociado'
end
