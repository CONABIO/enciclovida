class Historianatural < Ficha

	#establish_connection(:fichasespecies)

 	# Asignación de tabla
	self.table_name = 'historianatural'

	self.primary_keys = :historiaNaturalId,  :especieId

	belongs_to :cat_estrategiaTrofica, :class_name => 'Cat_Estrategiatrofica', :foreign_key => 'IdEstrategia'
	belongs_to :reproduccionAnimal, :class_name => 'Reproduccionanimal', :foreign_key => 'reproduccionAnimalId'
	belongs_to :reproduccionVegetal, :class_name => 'Reproduccionvegetal', :foreign_key => 'reproduccionVegetalId'
	belongs_to :taxon, :class_name => 'Taxon', :foreign_key => 'especieId'

	has_many :relHistoriasNaturalesPais, class_name: 'Relhistorianaturalpais'
	has_many :relHistoriasNaturalesUsos, class_name: 'Relhistorianaturalusos', :foreign_key => 'historiaNaturalId'

	has_many :culturaUsos, class_name: 'Culturausos', through: :relHistoriasNaturalesUsos

	def get_info_reproduccion
		if self.tipoReproduccion == 'animal'
			return self.reproduccionAnimal
		else
			return self.reproduccionVegetal
		end
	end

end
