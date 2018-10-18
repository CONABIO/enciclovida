class Organizacion < Ficha

	# Asignación de tabla
	self.table_name = 'organizacion'

	self.primary_key = 'organizacionId'

	has_many :asociados, :class_name => 'Asociado'
end
