class Fichas::MunicipioF < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.municipio"
	self.primary_key = 'municipioId'

	has_many :relDistribucionesMunicipios, class_name: 'Fichas::Reldistribucionmunicipio'

end
