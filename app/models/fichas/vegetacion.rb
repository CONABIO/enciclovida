class Vegetacion < ActiveRecord::Base
	establish_connection(:fichasespecies)
 	# Asignación de tabla
	self.table_name = 'vegetacion'

	self.primary_key = 'vegetacionId'

	has_many :relHabitatsVegetaciones , class_name: 'Relhabitatvegetacion'
end
