class Fichas::Relmetadatosasociado < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.relmetadatosasociado"
	self.primary_key = [:asociadoId, :metadatosId]

	belongs_to :asociado, :class_name => 'Fichas::Asociado', :foreign_key => 'asociadoId', primary_key: :asociadoId
	belongs_to :metadatos, :class_name => 'Fichas::Metadatos', foreign_key: :metadatosId, primary_key: :metadatosId

end
