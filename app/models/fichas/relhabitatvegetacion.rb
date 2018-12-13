class Relhabitatvegetacion < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.relhabitatvegetacion"
	self.primary_keys = :habitatId,  :vegetacionId,  :observaciones

	belongs_to :habitat, :class_name => 'Habitat', :foreign_key => 'habitatId'
	belongs_to :vegetacion, :class_name => 'Vegetacion', :foreign_key => 'vegetacionId'

end
