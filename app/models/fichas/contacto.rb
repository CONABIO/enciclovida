class Contacto < Ficha
	#establish_connection(:fichasespecies)
 	# Asignación de tabla
	self.table_name = 'contacto'

	self.primary_key = 'contactoId'

	belongs_to :ciudad, :class_name => 'Ciudad', :foreign_key => 'ciudadId'

	has_many :relAsociadosContactos, class_name: 'Relasociadocontacto'
end
