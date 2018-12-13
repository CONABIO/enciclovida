class Reproduccionanimal < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.reproduccionanimal"
	self.primary_key = 'reproduccionAnimalId'

	has_one :historiaNatural, class_name: 'Historianatural'

end
