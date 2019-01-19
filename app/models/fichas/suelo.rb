class Fichas::Suelo < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.suelo"
	self.primary_key = 'sueloId'

	has_many :habitat, class_name: 'Fichas::Habitat'

end
