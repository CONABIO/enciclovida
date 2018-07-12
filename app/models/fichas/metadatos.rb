class Metadatos < ActiveRecord::Base

	establish_connection(:fichasespecies)
 	# Asignación de tabla
	self.table_name = 'metadatos'

	self.primary_keys = :metadatosId,  :especieId

	belongs_to :taxon, :class_name => 'Taxon', :foreign_key => 'especieId'

	has_many :relMetadatosAsociados , class_name: 'Relmetadatosasociado'
end
