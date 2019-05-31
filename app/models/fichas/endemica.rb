class Fichas::Endemica < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.endemica"
	self.primary_keys = :endemicaId,  :especieId

	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId'

	ENDEMICA_MEXICO = [
			'Sí'.to_sym,
      'no'.to_sym
	]
end
