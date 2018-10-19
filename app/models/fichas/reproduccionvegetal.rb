class Reproduccionvegetal < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.reproduccionvegetal"
	self.primary_key = 'reproduccionVegetalId'

	belongs_to :cat_caracfruto, :class_name => 'Cat_Caracfruto', :foreign_key => 'IdFruto'
	has_one :historiaNatural, class_name: 'Historianatural'

end
