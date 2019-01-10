class Fichas::Interaccion < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.interaccion"
	self.primary_key = 'interaccionId'

	has_many :demografiasAmenazas, :class_name=> 'Demografiaamenazas'

end
