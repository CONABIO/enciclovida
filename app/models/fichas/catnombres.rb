class Catnombres < ActiveRecord::Base
	establish_connection(:fichasespecies)
	# Asignación manual a la tabla 
	self.table_name = 'catnombres'
end
