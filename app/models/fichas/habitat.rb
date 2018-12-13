class Habitat < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.habitat"
	self.primary_keys = :habitatId,  :especieId

	belongs_to :geoforma, :class_name => 'Geoforma', :foreign_key => 'geoformaId'
	belongs_to :suelo, :class_name => 'Suelo', :foreign_key => 'sueloId'
	belongs_to :taxon, :class_name => 'Taxon', :foreign_key => 'especieId'
	belongs_to :tipoclima, :class_name => 'Tipoclima', :foreign_key => 'tipoClimaId'
	belongs_to :habitatAntropico, :class_name => 'Habitatantropico', :foreign_key => 'habitatAntropicoId'
	has_many :relEcorregionesHabitats, class_name: 'Relecorregionhabitat', :foreign_key => 'ecorregionId'
	has_many :relEcosistemasHabitats, class_name: 'Relecosistemahabitat', :foreign_key => 'ecosistemaid'
	has_many :relHabitatsVegetaciones , class_name: 'Relhabitatvegetacion'
	has_many :relVegetacionesAcuaticasHabitats , class_name: 'Relvegetacionacuaticahabitat'

	has_many :ecorregion, class_name: 'Ficha_Ecorregion', through: :relEcorregionesHabitats
  has_many :ecosistema, class_name: 'Ecosistema', through: :relEcosistemasHabitats

end
