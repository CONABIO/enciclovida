class Fichas::Endemica < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.endemica"
	self.primary_keys = :endemicaId,  :especieId

	belongs_to :taxon, :class_name => 'Taxon', :foreign_key => 'especieId'

end
