class Endemica < ActiveRecord::Base

	establish_connection(:fichasespecies)

 	# Asignación de tabla
	self.table_name = 'endemica'

	self.primary_keys = :endemicaId,  :especieId

	belongs_to :taxon, :class_name => 'Taxon', :foreign_key => 'especieId'
end
