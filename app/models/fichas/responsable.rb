class Responsable < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.responsable"
	self.primary_key = 'responsableId'

	has_many :asociados, :class_name => 'Asociado'

end
