class Fichas::Cat_Caracteristica < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.cat_caracteristica"
	self.primary_key = 'idpregunta'

end
