class Fichas::Habitat < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.habitat"
	self.primary_keys = :habitatId,  :especieId

	belongs_to :geoforma, :class_name => 'Fichas::Geoforma', :foreign_key => 'geoformaId'
	belongs_to :suelo, :class_name => 'Fichas::Suelo', :foreign_key => 'sueloId'
	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId'
	belongs_to :tipoclima, :class_name => 'Fichas::Tipoclima', :foreign_key => 'tipoClimaId'
	belongs_to :habitatAntropico, :class_name => 'Fichas::Habitatantropico', :foreign_key => 'habitatAntropicoId'
	has_many :relEcorregionesHabitats, class_name: 'Fichas::Relecorregionhabitat', :foreign_key => 'ecorregionId'
	has_many :relEcosistemasHabitats, class_name: 'Fichas::Relecosistemahabitat', :foreign_key => 'ecosistemaid'
	has_many :relHabitatsVegetaciones , class_name: 'Fichas::Relhabitatvegetacion'
	has_many :relVegetacionesAcuaticasHabitats , class_name: 'Fichas::Relvegetacionacuaticahabitat'

	has_many :ecorregion, class_name: 'Fichas::Ficha_Ecorregion', through: :relEcorregionesHabitats
  has_many :ecosistema, class_name: 'Fichas::Ecosistema', through: :relEcosistemasHabitats

end
