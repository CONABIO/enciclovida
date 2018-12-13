class Reldistribucionestado < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.reldistribucionestado"
	self.primary_keys = :distribucionId,  :estadoId

	belongs_to :distribucion, :class_name => 'Distribucion', :foreign_key => 'distribucionId'
	belongs_to :estado, :class_name => 'EstadoF', :foreign_key => 'estadoId'

end
