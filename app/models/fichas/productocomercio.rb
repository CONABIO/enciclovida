class Fichas::Productocomercio < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.productocomercio"
	self.primary_keys = :especieId

	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId'

end
