class Cat_Nombres < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.cat_nombres"
	self.primary_key = 'IdNombre'

end
