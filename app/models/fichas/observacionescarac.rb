class Fichas::Observacionescarac < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.observacionescarac"
	self.primary_keys = :especieId,  :idpregunta

  has_many :habitats, class_name: 'Fichas::Habitat', :foreign_key => 'especieId', :primary_key => :especieId

	PREGUNTAS = {
			:info_ecorregiones => 52
	}


end