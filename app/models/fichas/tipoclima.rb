class Tipoclima < Ficha

	# Asignación de tabla
	self.table_name = 'tipoclima'

	self.primary_key = 'tipoClimaId'

	has_many :habitats, class_name: 'Habitat'
end
