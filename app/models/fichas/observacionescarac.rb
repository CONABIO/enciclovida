class Fichas::Observacionescarac < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.observacionescarac"
	self.primary_key = :especieId

  belongs_to :taxon, class_name: 'Fichas::Taxon', :foreign_key => 'especieId'
	validates_uniqueness_of :especieId, :scope => :idpregunta

	PREGUNTAS = {
			:ambi_especies_asociadas => 2,
      :ambi_vegetacion_esp_mundo => 3,
      :ambi_info_clima_exotico => 5,
			:info_ecorregiones => 52
	}

end