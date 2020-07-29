class Fichas::Cat_Preguntas < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.cat_preguntas"
	self.primary_key = 'idopcion'

	scope :tipos_vegetacion, -> { where(idpregunta: 3) }
end
