class Fichas::Geoforma < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.geoforma"
	self.primary_key = 'IdGeoforma'

	has_many :habitat, class_name: 'Fichas::Habitat'

	has_many :caracteristicaEespecie,-> {where('caracteristicasespecie.idpregunta' => 7)}, class_name: 'Fichas::Caracteristicasespecie', :foreign_key => "especieId"

end
