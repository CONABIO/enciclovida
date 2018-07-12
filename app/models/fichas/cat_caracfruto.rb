class Cat_Caracfruto < ActiveRecord::Base

	establish_connection(:fichasespecies)

 	# Asignación de tabla
	self.table_name = 'cat_caracfruto'

	self.primary_key = 'IdFruto'

	has_one :reproduccionVegetal , class_name: 'Reproduccionvegetal'
end
