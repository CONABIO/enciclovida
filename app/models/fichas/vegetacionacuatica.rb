class Vegetacionacuatica < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.vegetacionacuatica"

	has_many :relVegetacionesAcuaticasHabitats , class_name: 'Relvegetacionacuaticahabitat'
	
end
