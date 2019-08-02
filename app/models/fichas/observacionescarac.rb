class Fichas::Observacionescarac < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.observacionescarac"
	self.primary_keys = :especieId,  :idpregunta

	PREGUNTAS = {
			:info_ecorregiones => 52
	}

end