class Fichas::Suelo < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.suelo"
	self.primary_key = 'sueloId'

	has_many :habitat, class_name: 'Fichas::Habitat'

	def tiene_datos_amb?
		return true if descripcion.present?
	end

end
