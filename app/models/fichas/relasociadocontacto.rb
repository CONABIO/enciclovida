class RelAsociadoContacto < ActiveRecord::Base
	establish_connection(:fichasespecies)
 	# Asignación de tabla
	self.table_name = 'relasociadocontacto'

	self.primary_keys = :asociadoId,  :contactoId

	belongs_to :asociado, :class_name => 'Asociado', :foreign_key => 'asociadoId'
	belongs_to :contacto, :class_name => 'Contacto', :foreign_key => 'contactoId'
end
