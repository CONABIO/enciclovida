class Rutas < Ficha

	# Asignación de tabla
	self.table_name = 'rutas'

	self.primary_keys = :especieId,  :categoriaruta

end
