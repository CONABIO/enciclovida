class Relhistorianaturalusos < Ficha

	# Asignación de tabla
	self.table_name = 'relhistorianaturalusos'

	self.primary_keys = :historiaNaturalId,  :culturaUsosId

	belongs_to :culturaUsos, :class_name => 'Culturausos', :foreign_key => 'culturaUsosId'
	belongs_to :historiaNatural, :class_name => 'Historianatural', :foreign_key => 'historiaNaturalId'

end
