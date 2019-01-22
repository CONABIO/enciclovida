class Fichas::Metadatos < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.metadatos"
	self.primary_keys = :metadatosId,  :especieId

	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId'
	has_many :relMetadatosAsociados , class_name: 'Fichas::Relmetadatosasociado', :foreign_key => 'asociadoId'
	has_many :asociado, class_name: 'Fichas::Asociado', through: :relMetadatosAsociados

end
