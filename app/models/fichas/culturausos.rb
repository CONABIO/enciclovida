class Culturausos < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.culturausos"
	self.primary_key = 'culturaUsosId'

	has_many :relHistoriasNaturalesUsos , class_name: 'Relhistorianaturalusos'

end
