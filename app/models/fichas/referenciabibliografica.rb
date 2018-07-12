class ReferenciaBibliografica < ActiveRecord::Base
	establish_connection(:fichasespecies)
 	# Asignación de tabla
	self.table_name = 'referenciabibliografica'

	self.primary_keys = :referenciaId,  :especieId

	belongs_to :taxon, :class_name => 'Taxon', :foreign_key => 'especieId'
end
