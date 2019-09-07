class Fichas::Habitat < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.habitat"
	self.primary_key = :habitatId

	#belongs_to :geoforma, :class_name => 'Fichas::Geoforma', :foreign_key => 'geoformaId'
	#belongs_to :suelo, :class_name => 'Fichas::Suelo', :foreign_key => 'sueloId'
	#belongs_to :tipoclima, :class_name => 'Fichas::Tipoclima', :foreign_key => 'tipoClimaId'
	#belongs_to :habitatAntropico, :class_name => 'Fichas::Habitatantropico', :foreign_key => 'habitatAntropicoId'
  belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId'

	has_many :relEcorregionesHabitats, class_name: 'Fichas::Relecorregionhabitat', :foreign_key => 'habitatId'
	has_many :relEcosistemasHabitats, class_name: 'Fichas::Relecosistemahabitat', :foreign_key => 'habitatId'
	has_many :relHabitatsVegetaciones , class_name: 'Fichas::Relhabitatvegetacion', :foreign_key => 'habitatId'
	has_many :relVegetacionesAcuaticasHabitats , class_name: 'Fichas::Relvegetacionacuaticahabitat', :foreign_key => 'habitatId'

	has_many :ecorregion, class_name: 'Fichas::Ficha_Ecorregion', through: :relEcorregionesHabitats
  has_many :ecosistema, class_name: 'Fichas::Ecosistema', through: :relEcosistemasHabitats
	has_many :vegetacion, class_name: 'Fichas::Vegetacion', through: :relHabitatsVegetaciones
	has_many :vegetacion_acuatica, class_name: 'Fichas::Vegetacionacuatica', through: :relVegetacionesAcuaticasHabitats

  # - - - - - -   Preguntas de observaciones en la tabla Observacionescarac ( INFORMACIÓN ADICIONAL EN SU MAYORÍA ) - - - - - - #
	has_many :ambi_info_ecorregiones,-> {where('observacionescarac.idpregunta = ?', 52)}, class_name: 'Fichas::Observacionescarac',  foreign_key: :especieId, inverse_of: :taxon
	has_many :ambi_especies_asociadas,-> {where('observacionescarac.idpregunta = ?', 2)}, class_name: 'Fichas::Observacionescarac', primary_key: :especieId, foreign_key: :especieId, inverse_of: :taxon
	has_many :ambi_vegetacion_esp_mundo,-> {where('observacionescarac.idpregunta = ?', 3)}, class_name: 'Fichas::Observacionescarac', primary_key: :especieId, foreign_key: :especieId, inverse_of: :taxon
	has_many :ambi_info_clima_exotico,-> {where('observacionescarac.idpregunta = ?', 5)}, class_name: 'Fichas::Observacionescarac', primary_key: :especieId, foreign_key: :especieId, inverse_of: :taxon
	has_many :ambi_info_clima,-> {where('observacionescarac.idpregunta = ?', 4)}, class_name: 'Fichas::Observacionescarac', primary_key: :especieId, foreign_key: :especieId, inverse_of: :taxon
	has_many :ambi_infotiposuelo,-> {where('observacionescarac.idpregunta = ?', 6 )}, class_name: 'Fichas::Observacionescarac', primary_key: :especieId, foreign_key: :especieId, inverse_of: :taxon
	has_many :ambi_infogeoforma,-> {where('observacionescarac.idpregunta = ?', 7 )}, class_name: 'Fichas::Observacionescarac', primary_key: :especieId, foreign_key: :especieId, inverse_of: :taxon

	accepts_nested_attributes_for :ambi_info_ecorregiones, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :ambi_especies_asociadas, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :ambi_vegetacion_esp_mundo, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :ambi_info_clima, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :ambi_info_clima_exotico, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :ambi_infotiposuelo, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :ambi_infogeoforma, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }

	# Acceso a las opciones de catálogo
	accepts_nested_attributes_for :ecorregion, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :ecosistema, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :vegetacion, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :vegetacion_acuatica, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :relEcosistemasHabitats, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :relHabitatsVegetaciones, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :relEcorregionesHabitats, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :relVegetacionesAcuaticasHabitats, allow_destroy: true, reject_if: :all_blank

	ESTADOS_HABITAT = [
      'Hostil o muy limitante'.to_sym,
      'Intermedio o limitante'.to_sym,
      'Propicio o poco limitante'.to_sym
  ]

	TIPOS_HABITAT = [
			'terrestre'.to_sym,
			'acuático'.to_sym,
			'terrestre-acuático'.to_sym
	]

  UNIDAD_SALINIDAD = [
      'Porcentaje(%)'.to_sym,
      'Partes por mil(ppt)'.to_sym,
      'Gramos por litro(g/L)'.to_sym,
      'Unidades prácticas de salinidad(ups, psu)'.to_sym
  ]

end