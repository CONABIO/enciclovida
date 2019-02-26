class Fichas::Puesto < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.puesto"
	self.primary_key = 'puestoId'

	has_many :asociados, :class_name => 'Fichas::Asociado'

end
