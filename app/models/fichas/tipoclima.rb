class Tipoclima < Ficha

	#establish_connection(:fichasespecies)

 	# Asignación de tabla
	self.table_name = 'tipoclima'

	self.primary_key = 'tipoClimaId'

	has_many :habitats, class_name: 'Habitat'
end
