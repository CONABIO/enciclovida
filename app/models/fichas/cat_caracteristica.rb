class Cat_Caracteristica < ActiveRecord::Base

	establish_connection(:fichasespecies)

 	# Asignación de tabla
	self.table_name = 'cat_caracteristica'

	self.primary_key = 'idpregunta'

end
