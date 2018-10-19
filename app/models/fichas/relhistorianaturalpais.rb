class Relhistorianaturalpais < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.relhistorianaturalpais"
	self.primary_keys = :historiaNaturalId,  :paisId

	belongs_to :historiaNatural, :class_name => 'Historianatural', :foreign_key => 'historiaNaturalId'

end
