class Fichas::Productocomercio < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.productocomercio"
	self.primary_keys = :especieId,  :tipoproducto,  :nacionalinternacional

	belongs_to :taxon, :class_name => 'Taxon', :foreign_key => 'especieId'

end
