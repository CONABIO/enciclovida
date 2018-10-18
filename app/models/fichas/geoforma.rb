class Geoforma < Ficha

	# Asignación de tabla
	self.table_name = 'geoforma'

	self.primary_key = 'IdGeoforma'

	has_many :habitat, class_name: 'Habitat'
end
