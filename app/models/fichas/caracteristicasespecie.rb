class Caracteristicasespecie < Ficha

	# Asignación de tabla
	self.table_name = 'caracteristicasespecie'

	self.primary_keys = :especieId,  :idpregunta,  :idopcion

	belongs_to :taxon, :class_name => 'Taxon', :foreign_key => 'especieId'
end
