class Fichas::Endemica < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.endemica"
	self.primary_key = :endemicaId#,  :especieId

	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId', :primary_key => :especieId
end
