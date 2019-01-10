class Fichas::Cat_Gruposespecies < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.cat_gruposespecies"
	self.primary_key = 'Id'

	has_many :conservaciones, :class_name => 'Conservacion'

end
