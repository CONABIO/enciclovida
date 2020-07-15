class Fichas::Geoforma < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.geoforma"
	self.primary_key = 'IdGeoforma'

	has_many :habitat, class_name: 'Fichas::Habitat'

	def tiene_datos_amb?
		return true if descrpcion.present?
	end

end
