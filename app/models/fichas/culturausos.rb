class Culturausos < ActiveRecord::Base
	establish_connection(:fichasespecies)
 	# Asignación de tabla
	self.table_name = 'culturausos'

	self.primary_key = 'culturaUsosId'

	has_many :relHistoriasNaturalesUsos , class_name: 'Relhistorianaturalusos'
end