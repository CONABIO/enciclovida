class Fichas::Habitat < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.habitat"
	self.primary_keys = :habitatId,  :especieId

	belongs_to :geoforma, :class_name => 'Fichas::Geoforma', :foreign_key => 'geoformaId'
	belongs_to :suelo, :class_name => 'Fichas::Suelo', :foreign_key => 'sueloId'
	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId'
	belongs_to :tipoclima, :class_name => 'Fichas::Tipoclima', :foreign_key => 'tipoClimaId'
	belongs_to :habitatAntropico, :class_name => 'Fichas::Habitatantropico', :foreign_key => 'habitatAntropicoId'

	has_many :relEcorregionesHabitats, class_name: 'Fichas::Relecorregionhabitat', :foreign_key => 'habitatId'
	has_many :relEcosistemasHabitats, class_name: 'Fichas::Relecosistemahabitat', :foreign_key => 'habitatId'
	has_many :relHabitatsVegetaciones , class_name: 'Fichas::Relhabitatvegetacion', :foreign_key => 'habitatId'
	has_many :relVegetacionesAcuaticasHabitats , class_name: 'Fichas::Relvegetacionacuaticahabitat', :foreign_key => 'habitatId'

	has_many :ecorregion, class_name: 'Fichas::Ficha_Ecorregion', through: :relEcorregionesHabitats
  has_many :ecosistema, class_name: 'Fichas::Ecosistema', through: :relEcosistemasHabitats
	has_many :vegetacion, class_name: 'Fichas::Vegetacion', through: :relHabitatsVegetaciones
	has_many :vegetacion_acuatica, class_name: 'Fichas::Vegetacionacuatica', through: :relVegetacionesAcuaticasHabitats

	# PARA ACCEDER A LA TABLA CARACTERISTICAESPECIE
	has_many :caracteristicasEspecies, :class_name => 'Fichas::Caracteristicasespecie', :foreign_key => [:especieId], :primary_key => :especieId
	#has_many :clima,-> {where('caracteristicasespecie.idpregunta' => 4)}, class_name: 'Fichas::Tipoclima', through: :caracteristicasEspecies
  #has_many :suelo,-> {where('caracteristicasespecie.idpregunta' => 6)}, class_name: 'Fichas::Suelo', through: :caracteristicasEspecies
  #has_many :geoforma,-> {where('caracteristicasespecie.idpregunta' => 7)},:class_name => 'Fichas::Geoforma', through: :caracteristicasEspecies

	# Cat_preguntas: CONSIDERANDO QUE EN ESTA TABLA EDSTÂN TODOS LOS CATALOGOS JUNTOS


	accepts_nested_attributes_for :ecorregion, allow_destroy: true
	accepts_nested_attributes_for :ecosistema, allow_destroy: true
	accepts_nested_attributes_for :suelo, allow_destroy: true
	accepts_nested_attributes_for :geoforma, allow_destroy: true


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

	VEGETACION_SEC = [
			'Arbórea'.to_sym,
			'Arbustiva'.to_sym,
			'Herbácea'.to_sym
	]

  UNIDAD_SALINIDAD = [
      'Porcentaje(%)'.to_sym,
      'Partes por mil(ppt)'.to_sym,
      'Gramos por litro(g/L)'.to_sym,
      'Unidades prácticas de salinidad(ups, psu)'.to_sym
  ]


	#attr_accessor :ecorregion
end
