class Observacionescarac < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.observacionescarac"
	self.primary_keys = :especieId,  :idpregunta

end
