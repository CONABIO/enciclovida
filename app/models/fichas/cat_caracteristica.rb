class Cat_Caracteristica < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.cat_caracteristica"
	self.primary_key = 'idpregunta'

end
