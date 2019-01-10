class Fichas::Relecosistemahabitat < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.relecosistemahabitat"
	self.primary_keys = :habitatId,  :ecosistemaid

	belongs_to :ecosistema, :class_name => 'Ecosistema', :foreign_key => 'ecosistemaid'
	belongs_to :habitat, :class_name => 'Habitat', :foreign_key => 'habitatId'

end
