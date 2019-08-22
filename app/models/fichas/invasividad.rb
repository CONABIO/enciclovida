class Fichas::Invasividad < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.invasividad"
	self.primary_keys = :invaisvidadId, :especieId

	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId', :primary_key => :especieId
	has_many :caracteristicasEspecies, :class_name => 'Fichas::Caracteristicasespecie', :foreign_key => 'especieId', :primary_key => :especieId


	has_many :rutas, class_name: 'Fichas::Rutas', :foreign_key => 'especieId', :primary_key => :especieId
	has_many :t_naturalizacionsei, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies

	accepts_nested_attributes_for :rutas, reject_if: :all_blank, allow_destroy: true
	accepts_nested_attributes_for :caracteristicasEspecies, reject_if: :all_blank, allow_destroy: true

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

	CCA = [
		"Alto riesgo-rechazo".to_sym,
		"Bajo riesgo-Sin restricciones".to_sym,
		"Posible riesgo- requiere análisis más detallado".to_sym,
	]

	OTROS_RIESGOS = [
		"Aceptar-Bajo riesgo".to_sym,
		"Evaluar-Riesgo medio".to_sym,
		"Rechazar-Alto riesgo".to_sym
	]

	MERI = [
		"Muy Alto".to_sym,
		"Alto".to_sym,
		"Medio".to_sym,
		"Bajo".to_sym
	]

end
