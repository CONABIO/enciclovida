class Pais < Ficha

	# Asignación de tabla
	self.table_name = 'pais'

	self.primary_key = 'paisId'

	has_many :ciudad, :class_name => 'Ciudad', :foreign_key => 'ciudadId'
	has_many :relDistribucionesPaises, class_name: 'Reldistribucionpais'
end
