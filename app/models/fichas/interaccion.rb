class Interaccion < Ficha

	# Asignación de tabla
	self.table_name = 'interaccion'

	self.primary_key = 'interaccionId'

	has_many :demografiasAmenazas, :class_name=> 'Demografiaamenazas'

end
