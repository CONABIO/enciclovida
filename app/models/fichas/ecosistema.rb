class Ecosistema < Ficha
	#establish_connection(:fichasespecies)
 	# Asignación de tabla
	self.table_name = 'ecosistema'

	self.primary_key = 'ecosistemaid'

	has_many :relEcosistemasHabitats, class_name: 'Relecosistemahabitat'
end
