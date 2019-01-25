class Fichas::Relhabitatvegetacion < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.relhabitatvegetacion"
	self.primary_keys = :habitatId,  :vegetacionId,  :observaciones

	belongs_to :habitat, :class_name => 'Fichas::Habitat', :foreign_key => 'habitatId'
	belongs_to :vegetacion, :class_name => 'Fichas::Vegetacion', :foreign_key => 'vegetacionId'

end
