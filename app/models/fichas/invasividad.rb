class Fichas::Invasividad < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.invasividad"
	self.primary_keys = :invaisvidadId #,  :especieId

	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId', :primary_key => :especieId

	ESTADO_POBLACION = [
			"Población en expansión".to_sym,
			"Población estable".to_sym,
			"Población en declive".to_sym,
			"Se desconoce".to_sym
	]

  PERSISTENCIQ_POBLACION = [
		"Se extinguió".to_sym,
		"Pasajera".to_sym,
		"Persistente".to_sym,
		"Se desconoce".to_sym,
		"Temporal".to_sym
  ]

	ABUNDANCIA_POBLACION = [
		"Dominante".to_sym,
		"Común".to_sym,
		"Rara".to_sym,
		"Nula".to_sym,
		"Se desconoce".to_sym,
		"Monocultivo".to_sym
	]

	REGULACIONES = [
		"Se desconoce".to_sym,
		"No considerado".to_sym,
		"Restringido".to_sym,
		"Prohibida".to_sym
	]




end
