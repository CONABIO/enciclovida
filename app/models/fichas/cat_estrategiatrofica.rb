class Cat_Estrategiatrofica < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.cat_estrategiatrofica"
	self.primary_key = 'IdEstrategia'

	has_one :historiaNatural, class_name: 'Historianatural'

end
