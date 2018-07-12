class Habitatantropico < ActiveRecord::Base
	establish_connection(:fichasespecies)
 	# Asignación de tabla
	self.table_name = 'habitatAntropico'

	self.primary_key = 'habitatAntropicoId'

	has_one :habitat, class_name: 'Habitat'
end