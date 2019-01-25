class Fichas::Relhistorianaturalpais < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.relhistorianaturalpais"
	self.primary_keys = :historiaNaturalId,  :paisId

	belongs_to :historiaNatural, :class_name => 'Fichas::Historianatural', :foreign_key => 'historiaNaturalId'

end
