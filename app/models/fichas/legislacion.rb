class Fichas::Legislacion < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.legislacion"
	self.primary_keys = :legislacionId,  :especieId

	belongs_to :taxon, :class_name => 'Taxon', :foreign_key => 'especieId'

end
