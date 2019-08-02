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
	has_many :caracteristicasEspecies, :class_name => 'Fichas::Caracteristicasespecie', :foreign_key => 'especieId', :primary_key => :especieId

	has_many :ecorregion, class_name: 'Fichas::Ficha_Ecorregion', through: :relEcorregionesHabitats
  has_many :ecosistema, class_name: 'Fichas::Ecosistema', through: :relEcosistemasHabitats
	has_many :vegetacion, class_name: 'Fichas::Vegetacion', through: :relHabitatsVegetaciones
	has_many :vegetacion_acuatica, class_name: 'Fichas::Vegetacionacuatica', through: :relVegetacionesAcuaticasHabitats

	# Cat_preguntas: CONSIDERANDO QUE EN ESTA TABLA EDSTÂN TODOS LOS CATALOGOS JUNTOS
	has_many :t_clima, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
	has_many :t_tipoVegetacionSecundaria, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
	has_many :t_suelo, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
	has_many :t_geoforma, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
	has_many :t_habitatAntropico, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
	has_many :t_ecorregionMarinaN1, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
	has_many :t_zonaVida, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies

	# Extraer las observaciones de la especie a partir de: observacionescarac
	has_one :info_ecorregiones,-> {where('observacionescarac.idpregunta = ?', Fichas::Observacionescarac::PREGUNTAS[:info_ecorregiones])}, class_name: 'Fichas::Observacionescarac', :foreign_key => 'especieId', :primary_key => :especieId

	accepts_nested_attributes_for :info_ecorregiones, allow_destroy: true

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



=begin

	a) Indicar el o los tipos de vegetación
	en los que se desarrolla la especie: EXO:
			SELECT descripcionVegetacion FROM vegetacion GROUP BY descripcionVegetacion;
	has_many :tipoVegetacionMundial,-> {where('caracteristicasespecie.idpregunta = ?', 3)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
	has_many :climaExo,-> {where('caracteristicasespecie.idpregunta = ?', 5)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
=end
