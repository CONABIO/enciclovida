class Cat_Caracfruto < Ficha

	# Asignación de tabla
	self.table_name = 'cat_caracfruto'

	self.primary_key = 'IdFruto'

	has_one :reproduccionVegetal , class_name: 'Reproduccionvegetal'
end
