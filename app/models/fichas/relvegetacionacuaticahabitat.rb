class Fichas::Relvegetacionacuaticahabitat < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.relvegetacionacuaticahabitat"
	self.primary_keys = :habitatId,  :vegetacionAcuaticaid

	belongs_to :habitat, :class_name => 'Fichas::Habitat', :foreign_key => 'habitatId'
	belongs_to :vegetacionAcuatica, :class_name => 'Fichas::Vegetacionacuatica', :foreign_key => 'vegetacionAcuaticaid'

end
