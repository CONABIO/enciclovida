class Reldemografiaamenazas < Ficha

	# Asignación de tabla
	self.table_name = 'reldemografiaamenazas'

	self.primary_keys = :demografiaAmenazasId,  :amenazaId

	belongs_to :demografiaAmenazas, :class_name => 'Demografiaamenazas', :foreign_key => 'demografiaAmenazasId'
	belongs_to :amenazaDirecta, :class_name => 'Amenazadirecta', :foreign_key => 'amenazaId'

end
