class Fichas::Productocomercio < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.productocomercio"
	self.primary_key = [:especieId, :tipoproducto, :nacionalinternacional]

	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId'

end
