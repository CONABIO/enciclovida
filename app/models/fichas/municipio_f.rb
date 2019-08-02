class Fichas::Municipio_F < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.municipio"
	self.primary_key = 'municipioId'

	has_many :relDistribucionesMunicipios, class_name: 'Fichas::Reldistribucionmunicipio', :foreign_key => "municipioId"

	has_many :distribucion, :class_name => 'Fichas::Distribucion', :through => :relDistribucionesMunicipios

end
