class Rutas < ActiveRecord::Base
	establish_connection(:fichasespecies)
 	# Asignación de tabla
	self.table_name = 'rutas'

	self.primary_keys = :especieId,  :categoriaruta

end
