class Fichas::Reldistribucionpais < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.reldistribucionpais"
	self.primary_keys = :distribucionId,  :paisId,  :tipopais

	belongs_to :distribucion, :class_name => 'Fichas::Distribucion', :foreign_key => 'distribucionId'
	belongs_to :pais, :class_name => 'Fichas::Pais', :foreign_key => 'paisId'
	belongs_to :pais_inv, :class_name => 'Fichas::Pais', :foreign_key => 'paisId'
	belongs_to :pais_inv2, :class_name => 'Fichas::Pais', :foreign_key => 'paisId'
end
