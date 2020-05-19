class Fichas::Vegetacionacuatica < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.vegetacionacuatica"
	self.primary_key = 'vegetacionAcuaticaid'

	has_many :relVegetacionesAcuaticasHabitats , class_name: 'Fichas::Relvegetacionacuaticahabitat', foreign_key: 'vegetacionAcuaticaid'

end
