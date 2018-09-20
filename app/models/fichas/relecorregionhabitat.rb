class Relecorregionhabitat < Ficha
	#establish_connection(:fichasespecies)
 	# Asignación de tabla
	self.table_name = 'relecorregionhabitat'

	self.primary_keys = :habitatId,  :ecorregionId

	belongs_to :ecorregion, :class_name => 'Ficha_Ecorregion', :foreign_key => 'ecorregionId'
	belongs_to :habitat, :class_name => 'Habitat', :foreign_key => 'habitatId'

end
