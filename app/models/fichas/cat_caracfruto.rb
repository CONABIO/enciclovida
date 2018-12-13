class Cat_Caracfruto < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.cat_caracfruto"
	self.primary_key = 'IdFruto'

	has_one :reproduccionVegetal , class_name: 'Reproduccionvegetal'

end
