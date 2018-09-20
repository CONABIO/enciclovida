class Relhistorianaturalpais < Ficha

	# Asignación de tabla
	self.table_name = 'relhistorianaturalpais'

	self.primary_keys = :historiaNaturalId,  :paisId

	belongs_to :historiaNatural, :class_name => 'Historianatural', :foreign_key => 'historiaNaturalId'

end
