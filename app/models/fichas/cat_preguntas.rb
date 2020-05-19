class Fichas::Cat_Preguntas < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.cat_preguntas"
	self.primary_key = 'idopcion'

  has_many :caracteristicas, class_name: 'Fichas::Caracteristicasespecie', :foreign_key => "idopcion"
  has_many :taxon, class_name: 'Fichas::Taxon', through: :caracteristicas

end