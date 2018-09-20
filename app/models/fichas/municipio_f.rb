class MunicipioF < Ficha

	# Asignación de tabla
	self.table_name = 'municipio'

	self.primary_key = 'municipioId'

	has_many :relDistribucionesMunicipios, class_name: 'Reldistribucionmunicipio'
end
