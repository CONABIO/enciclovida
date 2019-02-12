class Fichas::Catnombres < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.catnombres"

end
