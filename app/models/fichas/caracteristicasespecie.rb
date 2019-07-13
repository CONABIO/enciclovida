class Fichas::Caracteristicasespecie < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.caracteristicasespecie"
	self.primary_keys = :especieId,  :idpregunta,  :idopcion

	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId'
	belongs_to :clima, :class_name => 'Fichas::Tipoclima', :foreign_key => 'idopcion'
	belongs_to :suelo, :class_name => 'Fichas::Suelo', :foreign_key => 'idopcion'
	belongs_to :geoforma, :class_name => 'Fichas::Geoforma', :foreign_key => 'idopcion'

	belongs_to :elClima, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'



end
