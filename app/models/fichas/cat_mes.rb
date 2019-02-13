class Fichas::Cat_Mes < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.cat_mes"
	self.primary_key = 'IdMes'

end
