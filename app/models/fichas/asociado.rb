class Asociado < ActiveRecord::Base

	establish_connection(:fichasespecies)

 	# Asignación de tabla
	self.table_name = 'asociado'

	self.primary_key = 'asociadoId'

	belongs_to :responsable, :class_name => 'Responsable', :foreign_key => 'responsableId'
	belongs_to :puesto, :class_name => 'Puesto', :foreign_key => 'puestoId'
	belongs_to :organizacion, :class_name => 'Organizacion', :foreign_key => 'organizacionId'

	has_many :relAsociadosContactos, class_name: 'Relasociadocontacto'
	has_many :relMetadatosAsociados , class_name: 'Relmetadatosasociado'
end
