class Fichas::Tipoclima < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.tipoclima"
	self.primary_key = 'tipoClimaId'

	has_many :habitats, class_name: 'Fichas::Habitat'

	has_many :caracteristicaEespecie,-> {where('caracteristicasespecie.idpregunta' => 4)}, class_name: 'Fichas::Caracteristicasespecie', :foreign_key => "especieId"
	has_many :taxon, :class_name => 'Fichas::Taxon', :through => :caracteristicaEespecie

end
