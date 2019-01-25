class Fichas::Cat_Invasnoencat < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.cat_invasnoencat"
	self.primary_key = 'IdCAT'

end
