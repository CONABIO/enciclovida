class Fichas::Estado_F < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.estado"
	self.primary_key = 'estadoId'

	has_many :relDistribucionesEstados, class_name: 'Fichas::Reldistribucionestado', :foreign_key => 'estadoId'
	has_many :distribucion, :class_name => 'Fichas::Distribucion', :through => :relDistribucionesEstados

end
