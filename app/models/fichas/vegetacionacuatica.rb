class Vegetacionacuatica < Ficha

	# Asignación manual a la tabla
	self.table_name = 'vegetacionacuatica'

	has_many :relVegetacionesAcuaticasHabitats , class_name: 'Relvegetacionacuaticahabitat'
end
