class Fichas::Relmetadatosasociado < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.relmetadatosasociado"
	self.primary_keys = :asociadoId,  :metadatosId

	belongs_to :asociado, :class_name => 'Fichas::Asociado', :foreign_key => 'asociadoId'
	belongs_to :metadatos, :class_name => 'Fichas::Metadatos', :foreign_key => 'metadatosId'

end
