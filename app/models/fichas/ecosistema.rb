class Fichas::Ecosistema < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.ecosistema"
	self.primary_key = 'ecosistemaid'

	has_many :relEcosistemasHabitats, class_name: 'Fichas::Relecosistemahabitat'

	def tiene_datos_amb?
		return true if tipoecosistema.present?
	end

end
