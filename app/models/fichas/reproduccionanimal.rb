class Reproduccionanimal < Ficha

	# Asignación de tabla
	self.table_name = 'reproduccionanimal'

	self.primary_key = 'reproduccionAnimalId'

	has_one :historiaNatural, class_name: 'Historianatural'
end
