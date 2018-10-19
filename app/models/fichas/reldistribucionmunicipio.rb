class Reldistribucionmunicipio < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.reldistribucionmunicipio"
	self.primary_keys = :distribucionId,  :municipioId

	belongs_to :distribucion, :class_name => 'Distribucion', :foreign_key => 'distribucionId'
	belongs_to :municipio, :class_name => 'MunicipioF', :foreign_key => 'municipioId'

end
