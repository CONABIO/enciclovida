class Fichas::Observacionescarac < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.observacionescarac"
	self.primary_key = :especieId #, :idpregunta

  has_many :habitats, class_name: 'Fichas::Habitat', :foreign_key => 'especieId'
	validates_uniqueness_of :especieId, :scope => :idpregunta

	PREGUNTAS = {
			:info_ecorregiones => 52
	}

end