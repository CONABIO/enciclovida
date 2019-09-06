class Fichas::Invasividad < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.invasividad"
	self.primary_keys = :invaisvidadId, :especieId

	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId', :primary_key => :especieId

	has_many :rutas, class_name: 'Fichas::Rutas', :foreign_key => 'especieId', :primary_key => :especieId

	# - - - - - -   Preguntas de observaciones en la tabla Observacionescarac ( INFORMACIÓN ADICIONAL EN SU MAYORÍA ) - - - - - - #
	#Preguntas para invasoras
	has_many :edopoblacion,-> {where('observacionescarac.idpregunta = ?', 52)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :persistenciapob,-> {where('observacionescarac.idpregunta = ?', 53)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :abundanciapob,-> {where('observacionescarac.idpregunta = ?', 54)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :historiaintro,-> {where('observacionescarac.idpregunta = ?', 55)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :otrossitios,-> {where('observacionescarac.idpregunta = ?', 56)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :adahabitat,-> {where('observacionescarac.idpregunta = ?', 57)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :adaclima,-> {where('observacionescarac.idpregunta = ?', 58)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :congeneres,-> {where('observacionescarac.idpregunta = ?', 59)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :frecintro,-> {where('observacionescarac.idpregunta = ?', 61)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :impactosei,-> {where('observacionescarac.idpregunta = ?', 62)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :impactobio,-> {where('observacionescarac.idpregunta = ?', 63)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :impactoeco,-> {where('observacionescarac.idpregunta = ?', 64)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :impactoinfra,-> {where('observacionescarac.idpregunta = ?', 65)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :impactosocial,-> {where('observacionescarac.idpregunta = ?', 66)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :impactootros,-> {where('observacionescarac.idpregunta = ?', 67)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :prevencion,-> {where('observacionescarac.idpregunta = ?', 71)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :manejocontrol,-> {where('observacionescarac.idpregunta = ?', 72)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :erradicacion,-> {where('observacionescarac.idpregunta = ?', 73)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :cuarentena,-> {where('observacionescarac.idpregunta = ?', 74)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :susceptibilidad,-> {where('observacionescarac.idpregunta = ?', 75)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :controlbiol,-> {where('observacionescarac.idpregunta = ?', 76)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :regulacion,-> {where('observacionescarac.idpregunta = ?', 77)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :benecologicos,-> {where('observacionescarac.idpregunta = ?', 78)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :beneconomicos,-> {where('observacionescarac.idpregunta = ?', 79)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :bensociales,-> {where('observacionescarac.idpregunta = ?', 80)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :conclimatica,-> {where('observacionescarac.idpregunta = ?', 81)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :conecologica,-> {where('observacionescarac.idpregunta = ?', 82)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :plasconductual,-> {where('observacionescarac.idpregunta = ?', 85)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :plasrepro,-> {where('observacionescarac.idpregunta = ?', 86)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :hibridacion,-> {where('observacionescarac.idpregunta = ?', 87)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :crecimientosei,-> {where('observacionescarac.idpregunta = ?', 90)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :spequivalentes,-> {where('observacionescarac.idpregunta = ?', 92)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :cca,-> {where('observacionescarac.idpregunta = ?', 93)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :fisk,-> {where('observacionescarac.idpregunta = ?', 94)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :fiisk,-> {where('observacionescarac.idpregunta = ?', 95)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :mfisk,-> {where('observacionescarac.idpregunta = ?', 96)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :miisk,-> {where('observacionescarac.idpregunta = ?', 97)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :aisk,-> {where('observacionescarac.idpregunta = ?', 98)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :tiisk,-> {where('observacionescarac.idpregunta = ?', 99)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :pier,-> {where('observacionescarac.idpregunta = ?', 100)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :meri,-> {where('observacionescarac.idpregunta = ?', 101)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :otroar,-> {where('observacionescarac.idpregunta = ?', 102)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :naturalizacion,-> {where('observacionescarac.idpregunta = ?', 36 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :mecanismoimpacto,-> {where('observacionescarac.idpregunta = ?', 33 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :efectoimpacto,-> {where('observacionescarac.idpregunta = ?', 34 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :intensidadimpacto,-> {where('observacionescarac.idpregunta = ?', 35 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :especiesasociadas,-> {where('observacionescarac.idpregunta = ?', 37 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :plasticidad,-> {where('observacionescarac.idpregunta = ?', 38 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :platencia,-> {where('observacionescarac.idpregunta = ?', 40 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :seguridad,-> {where('observacionescarac.idpregunta = ?', 41 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :enfermedadesei,-> {where('observacionescarac.idpregunta = ?', 42 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon

	# Acceso desde Cocoon
	# INVASORAS
	accepts_nested_attributes_for :edopoblacion, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :persistenciapob, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :abundanciapob, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :historiaintro, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :otrossitios, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :adahabitat, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :adaclima, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :congeneres, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :frecintro, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :impactosei, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :impactobio, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :impactoeco, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :impactoinfra, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :impactosocial, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :impactootros, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :prevencion, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :manejocontrol, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :erradicacion, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :cuarentena, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :susceptibilidad, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :controlbiol, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :regulacion, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :benecologicos, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :beneconomicos, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :bensociales, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :conclimatica, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :conecologica, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :plasconductual, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :plasrepro, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :hibridacion, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :crecimientosei, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :spequivalentes, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :cca, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :fisk, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :fiisk, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :mfisk, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :miisk, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :aisk, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :tiisk, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :pier, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :meri, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :otroar, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :naturalizacion, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :mecanismoimpacto, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :efectoimpacto, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :intensidadimpacto, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :especiesasociadas, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :plasticidad, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :platencia, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :seguridad, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :enfermedadesei, allow_destroy: true, reject_if: :all_blank

	accepts_nested_attributes_for :rutas, reject_if: :all_blank, allow_destroy: true

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
