class Catnombresinvas < ActiveRecord::Base
	establish_connection(:fichasespecies)
	# Asignación manual a la tabla 
	self.table_name = 'catnombresinvas'
end
