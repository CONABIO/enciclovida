class Cat_Invasnoencat < ActiveRecord::Base

	establish_connection(:fichasespecies)

 	# Asignación de tabla
	self.table_name = 'cat_invasnoencat'

	self.primary_key = 'IdCAT'

end
