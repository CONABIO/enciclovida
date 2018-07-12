class Cat_Preguntas < ActiveRecord::Base
	establish_connection(:fichasespecies)
 	# Asignación de tabla
	self.table_name = 'cat_preguntas'

	self.primary_key = 'idopcion'

end
