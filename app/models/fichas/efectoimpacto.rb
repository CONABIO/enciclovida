class Fichas::Efectoimpacto < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.efectoimpacto"
	self.primary_key = 'efectoImpactoId'

end
