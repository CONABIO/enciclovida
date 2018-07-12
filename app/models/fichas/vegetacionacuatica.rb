class Vegetacionacuatica < ActiveRecord::Base
	establish_connection(:fichasespecies)
	# Asignación manual a la tabla 
	self.table_name = 'vegetacionacuatica'

	has_many :relVegetacionesAcuaticasHabitats , class_name: 'Relvegetacionacuaticahabitat'
end
