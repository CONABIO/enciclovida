class Fichas::Caracteristicasespecie < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.caracteristicasespecie"
	self.primary_keys = :especieId,  :idpregunta,  :idopcion

	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId'
	belongs_to :clima, :class_name => 'Fichas::Tipoclima', :foreign_key => 'idopcion'

end
