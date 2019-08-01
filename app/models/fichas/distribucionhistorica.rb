class Fichas::Distribucionhistorica < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.distribucionhistorica"
	self.primary_key = :especieId

	belongs_to :distribucion, :class_name => 'Fichas::Distribucion', :foreign_key => 'especieId'

end
