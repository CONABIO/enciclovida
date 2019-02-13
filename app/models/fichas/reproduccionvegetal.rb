class Fichas::Reproduccionvegetal < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.reproduccionvegetal"
	self.primary_key = 'reproduccionVegetalId'

	belongs_to :cat_caracfruto, :class_name => 'Fichas::Cat_Caracfruto', :foreign_key => 'IdFruto'
	has_one :historiaNatural, class_name: 'Fichas::Historianatural'

end
