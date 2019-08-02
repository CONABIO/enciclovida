class Fichas::Cat_Preguntas < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.cat_preguntas"
	self.primary_key = 'idopcion'

	has_many :clima,-> {where('caracteristicasespecie.idpregunta = ?', 4)}, class_name: 'Fichas::Caracteristicasespecie', foreign_key: 'idopcion'

end