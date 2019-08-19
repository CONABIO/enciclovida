class Fichas::Rutas < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.rutas"
	self.primary_key = :especieId

	belongs_to :invasividad, :class_name => 'Fichas::Invasividad', :foreign_key => 'especieId', :primary_key => :especieId
end
