class Cat_Gruposespecies < Ficha

	# Asignación de tabla
	self.table_name = 'cat_gruposespecies'

	self.primary_key = 'Id'

	has_many :conservaciones, :class_name => 'Conservacion'
end
