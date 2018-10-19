class EstadoF < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.estado"
	self.primary_key = 'estadoId'

	has_many :relDistribucionesEstados, class_name: 'Reldistribucionestado'

end
