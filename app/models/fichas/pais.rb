class Fichas::Pais < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.pais"
	self.primary_key = 'paisId'

	has_many :ciudad, :class_name => 'Ciudad', :foreign_key => 'ciudadId'
	has_many :relDistribucionesPaises, class_name: 'Reldistribucionpais'

end
