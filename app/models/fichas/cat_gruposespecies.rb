class Cat_Gruposespecies < ActiveRecord::Base

	establish_connection(:fichasespecies)

 	# Asignación de tabla
	self.table_name = 'cat_gruposespecies'

	self.primary_key = 'Id'

	has_many :conservaciones, :class_name => 'Conservacion'
end
