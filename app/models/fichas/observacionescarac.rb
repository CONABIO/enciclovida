class Fichas::Observacionescarac < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.observacionescarac"
	self.primary_keys = :especieId,  :idpregunta

	scope :vegetacion_mundial, -> { where(idpregunta: 3) }

end
