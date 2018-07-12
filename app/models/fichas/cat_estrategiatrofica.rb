class Cat_Estrategiatrofica < ActiveRecord::Base

	establish_connection(:fichasespecies)

 	# Asignación de tabla
	self.table_name = 'cat_estrategiatrofica'

	self.primary_key = 'IdEstrategia'

	has_one :historiaNatural, class_name: 'Historianatural'
end
