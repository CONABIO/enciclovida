class Responsable < Ficha

	# Asignación de tabla
	self.table_name = 'responsable'

	self.primary_key = 'responsableId'

	# Un responsable tiene muchos asociados
	has_many :asociados, :class_name => 'Asociado'
end
