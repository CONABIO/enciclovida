class Fichas::MunicipioF < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.municipio"
	self.primary_key = 'municipioId'

	has_many :relDistribucionesMunicipios, class_name: 'Reldistribucionmunicipio'

end
