class Fichas::Sinonimo < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.sinonimo"
	self.primary_keys = :especieId,  :nombreSimple,  :autoridad

	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId'

end
