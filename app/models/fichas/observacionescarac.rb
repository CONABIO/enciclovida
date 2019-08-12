class Fichas::Observacionescarac < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.observacionescarac"
	self.primary_keys = :especieId, :idpregunta

  belongs_to :taxon, class_name: 'Fichas::Taxon', :foreign_key => 'especieId'
  
	PREGUNTAS = {
			:ambi_especies_asociadas => 2,
      :ambi_vegetacion_esp_mundo => 3,
      :ambi_info_clima_exotico => 5,
			:info_ecorregiones => 52
	}

end