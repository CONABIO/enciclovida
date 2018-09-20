class Nombrecomun < Ficha

	#establish_connection(:fichasespecies)

 	# Asignación de tabla
	self.table_name = 'nombrecomun'

	self.primary_keys = :especieId,  :nombre

  belongs_to :taxon, :class_name => 'Taxon', :foreign_key => 'especieId'
end
