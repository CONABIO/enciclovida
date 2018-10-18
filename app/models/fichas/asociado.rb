class Asociado < Ficha

	# Asignación de tabla
	self.table_name = 'asociado'

	self.primary_key = 'asociadoId'

	belongs_to :responsable, :class_name => 'Responsable', :foreign_key => 'responsableId'
	belongs_to :puesto, :class_name => 'Puesto', :foreign_key => 'puestoId'
	belongs_to :organizacion, :class_name => 'Organizacion', :foreign_key => 'organizacionId'

	has_many :relAsociadosContactos, class_name: 'Relasociadocontacto', :foreign_key => 'contactoId'
	has_many :relMetadatosAsociados , class_name: 'Relmetadatosasociado', :foreign_key => 'metadatosId'

	has_many :contacto, class_name: 'Contacto', through: :relAsociadosContactos

end
