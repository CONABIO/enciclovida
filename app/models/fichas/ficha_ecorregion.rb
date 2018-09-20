class Ficha_Ecorregion < Ficha
	#establish_connection(:fichasespecies)
 	# Asignación de tabla
	self.table_name = 'ecorregion'

	self.primary_key = 'ecorregionId'

	has_many :relEcorregionesHabitats, class_name: 'Relecorregionhabitat'

end
