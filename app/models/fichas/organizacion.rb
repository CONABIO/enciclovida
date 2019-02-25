class Fichas::Organizacion < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.organizacion"
	self.primary_key = 'organizacionId'

	has_many :asociados, :class_name => 'Fichas::Asociado'

end
