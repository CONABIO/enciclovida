class Fichas::Reldistribucionestado < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.reldistribucionestado"
	self.primary_keys = :distribucionId,  :estadoId

	belongs_to :distribucion, :class_name => 'Fichas::Distribucion', :foreign_key => 'distribucionId'
	belongs_to :estado, :class_name => 'Fichas::EstadoF', :foreign_key => 'estadoId'

end
