class Fichas::Habitatantropico < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.habitatantropico"
	self.primary_key = 'habitatAntropicoId'

	has_one :habitat, class_name: 'Fichas::Habitat'

	def tiene_datos_amb?
		return true if descripcion.present?
	end

end