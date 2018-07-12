class Amenazadirecta < ActiveRecord::Base

	establish_connection(:fichasespecies)

 	# Asignación de tabla
	self.table_name = 'amenazadirecta'

	self.primary_key = 'amenazaId'

	has_many :relDemografiaAmenazas, class_name: 'Reldemografiaamenazas'
end
