class Relecosistemahabitat < Ficha
	#establish_connection(:fichasespecies)
 	# Asignación de tabla
	self.table_name = 'relecosistemahabitat'

	self.primary_keys = :habitatId,  :ecosistemaid

	belongs_to :ecosistema, :class_name => 'Ecosistema', :foreign_key => 'ecosistemaid'
	belongs_to :habitat, :class_name => 'Habitat', :foreign_key => 'habitatId'

end
