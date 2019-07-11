class Fichas::Ficha_Ecorregion < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.ecorregion"
	self.primary_key = 'ecorregionId'

	has_many :relEcorregionesHabitats, class_name: 'Fichas::Relecorregionhabitat'
	has_many :habitats, class_name: 'Fichas::Habitat', through: :relEcorregionesHabitats
end
