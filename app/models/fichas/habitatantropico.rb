class Habitatantropico < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.habitatAntropico"
	self.primary_key = 'habitatAntropicoId'

	has_one :habitat, class_name: 'Habitat'

end