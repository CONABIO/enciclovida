class Efectoimpacto < ActiveRecord::Base
	establish_connection(:fichasespecies)
 	# Asignación de tabla
	self.table_name = 'efectoimpacto'

	self.primary_key = 'efectoImpactoId'

end
