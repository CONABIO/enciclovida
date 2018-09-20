class Reldistribucionpais < Ficha

	# Asignación de tabla
	self.table_name = 'reldistribucionpais'

	self.primary_keys = :distribucionId,  :paisId,  :tipopais

	belongs_to :distribucion, :class_name => 'Distribucion', :foreign_key => 'distribucionId'
	belongs_to :pais, :class_name => 'Pais', :foreign_key => 'paisId'

end
