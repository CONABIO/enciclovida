class Fichas::Observacionescarac < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.observacionescarac"
	self.primary_key = :especieId

  belongs_to :taxon, class_name: 'Fichas::Taxon', :foreign_key => 'especieId'
	validates_uniqueness_of :especieId, :scope => :idpregunta

	PREGUNTAS = {
			:info_ecorregiones => 52
	}

end