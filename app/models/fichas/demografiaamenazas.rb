class Demografiaamenazas < ActiveRecord::Base
	establish_connection(:fichasespecies)
 	# Asignación de tabla
	self.table_name = 'demografiaamenazas'

	self.primary_keys = :demografiaAmenazasId,  :especieId

	belongs_to :interaccion, :class_name => 'Interaccion', :foreign_key => 'interaccionId'
	belongs_to :taxon, :class_name => 'Taxon', :foreign_key => 'especieId'

	has_many :relDemografiasAmenazas, class_name: 'Reldemografiaamenazas', :foreign_key => 'demografiaAmenazasId'

	has_many :amenazaDirecta, class_name: 'Amenazadirecta', through: :relDemografiasAmenazas

end
