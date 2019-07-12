class Fichas::Pais < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.pais"
	self.primary_key = 'paisId'

	has_many :ciudad, :class_name => 'Fichas::Ciudad', :foreign_key => 'ciudadId'

	has_many :relDistribucionesPaises, class_name: 'Fichas::Reldistribucionpais', :foreign_key => "paisId"
	has_many :distribucion, :class_name => 'Fichas::Distribucion', :through => :relDistribucionesPaises

end
