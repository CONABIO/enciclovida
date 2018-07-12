class Cat_Nombres < ActiveRecord::Base
	establish_connection(:fichasespecies)
 	# Asignación de tabla
	self.table_name = 'cat_nombres'

	self.primary_key = 'IdNombre'

end
