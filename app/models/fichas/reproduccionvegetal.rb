class Reproduccionvegetal < Ficha

	# Asignación de tabla
	self.table_name = 'reproduccionvegetal'

	self.primary_key = 'reproduccionVegetalId'

	belongs_to :cat_caracfruto, :class_name => 'Cat_Caracfruto', :foreign_key => 'IdFruto'

	has_one :historiaNatural, class_name: 'Historianatural'
end
