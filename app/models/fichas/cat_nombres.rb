class Fichas::Cat_Nombres < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.cat_nombres"
	self.primary_key = 'IdNombre'

end
