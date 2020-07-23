class Fichas::Tipoclima < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.tipoclima"
	self.primary_key = 'tipoClimaId'

	has_many :habitats, class_name: 'Fichas::Habitat'

	def tiene_datos_amb?
		return true if clima.present?
	end

end
