class Fichas::Observacionescarac < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.observacionescarac"
	self.primary_keys = :especieId, :idpregunta

  belongs_to :taxon, class_name: 'Fichas::Taxon', :foreign_key => 'especieId'
  
	PREGUNTAS = {
			:info_ecorregiones => 52
	}

end