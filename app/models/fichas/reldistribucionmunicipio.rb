class Reldistribucionmunicipio < Ficha
	#establish_connection(:fichasespecies)
 	# Asignación de tabla
	self.table_name = 'reldistribucionmunicipio'

	self.primary_keys = :distribucionId,  :municipioId

	belongs_to :distribucion, :class_name => 'Distribucion', :foreign_key => 'distribucionId'
	belongs_to :municipio, :class_name => 'MunicipioF', :foreign_key => 'municipioId'

end
