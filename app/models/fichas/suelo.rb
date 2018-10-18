class Suelo < Ficha

	# Asignación de tabla
	self.table_name = 'suelo'

	self.primary_key = 'sueloId'

	has_many :habitat, class_name: 'Habitat'
end
