class Fichas::Endemica < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.endemica"
	self.primary_keys = :endemicaId,  :especieId

	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId'

	def tiene_datos?
		return true if endemicaA.present? || infoAdicionalEndemica.present?
	end

end
