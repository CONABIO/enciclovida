class Fichas::Ficha_Ecorregion < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.ecorregion"
	self.primary_key = 'ecorregionId'

	has_many :relEcorregionesHabitats, class_name: 'Relecorregionhabitat'

end
