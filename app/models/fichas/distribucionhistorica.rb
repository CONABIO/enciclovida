class Fichas::Distribucionhistorica < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.distribucionhistorica"
	self.primary_keys = :especieId, :regLoc

	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId'

end
