class Invasividad < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.invasividad"
	self.primary_keys = :invaisvidadId,  :especieId

end
