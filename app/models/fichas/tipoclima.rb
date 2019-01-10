class Fichas::Tipoclima < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.tipoclima"
	self.primary_key = 'tipoClimaId'

	has_many :habitats, class_name: 'Habitat'

end
