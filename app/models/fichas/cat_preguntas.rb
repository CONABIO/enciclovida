class Fichas::Cat_Preguntas < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.cat_preguntas"
	self.primary_key = 'idopcion'

end
