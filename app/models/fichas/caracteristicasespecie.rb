class Fichas::Caracteristicasespecie < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.caracteristicasespecie"
	self.primary_keys = :especieId,  :idpregunta,  :idopcion

	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId'

end
