class Vegetacion < Ficha

	# Asignación de tabla
	self.table_name = 'vegetacion'

	self.primary_key = 'vegetacionId'

	has_many :relHabitatsVegetaciones , class_name: 'Relhabitatvegetacion'
end
