class Cat_Nombres < Ficha
	#establish_connection(:fichasespecies)
 	# Asignación de tabla
	self.table_name = 'cat_nombres'

	self.primary_key = 'IdNombre'

end
