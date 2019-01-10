class Fichas::Nombrecomun < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.nombrecomun"
	self.primary_keys = :especieId,  :nombre

  belongs_to :taxon, :class_name => 'Taxon', :foreign_key => 'especieId'

end
