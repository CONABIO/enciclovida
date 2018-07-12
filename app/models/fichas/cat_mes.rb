class Cat_Mes < ActiveRecord::Base
	establish_connection(:fichasespecies)

 	# Asignación de tabla
	self.table_name = 'cat_mes'

	self.primary_key = 'IdMes'

end
