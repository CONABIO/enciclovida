class Fichas::Metadatos < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.metadatos"
	self.primary_keys = :metadatosId,  :especieId

	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId'

	has_many :relMetadatosAsociados , class_name: 'Fichas::Relmetadatosasociado', foreign_key: :metadatosId, primary_key: :metadatosId, inverse_of: :metadatos
	has_many :asociado, through: :relMetadatosAsociados

	accepts_nested_attributes_for :relMetadatosAsociados, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :asociado, allow_destroy: true, reject_if: :all_blank

end
