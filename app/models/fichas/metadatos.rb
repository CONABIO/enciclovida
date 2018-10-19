class Metadatos < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.metadatos"
	self.primary_keys = :metadatosId,  :especieId

	belongs_to :taxon, :class_name => 'Taxon', :foreign_key => 'especieId'
	has_many :relMetadatosAsociados , class_name: 'Relmetadatosasociado', :foreign_key => 'asociadoId'
	has_many :asociado, class_name: 'Asociado', through: :relMetadatosAsociados

end
