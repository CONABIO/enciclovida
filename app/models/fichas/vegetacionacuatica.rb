class Fichas::Vegetacionacuatica < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.vegetacionacuatica"

	has_many :relVegetacionesAcuaticasHabitats , class_name: 'Fichas::Relvegetacionacuaticahabitat'

end
