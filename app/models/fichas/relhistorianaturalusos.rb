class Fichas::Relhistorianaturalusos < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.relhistorianaturalusos"
	self.primary_keys = :historiaNaturalId,  :culturaUsosId

	belongs_to :culturaUsos, :class_name => 'Fichas::Culturausos', :foreign_key => 'culturaUsosId', :primary_key => :culturaUsosId
	belongs_to :historiaNatural, :class_name => 'Fichas::Historianatural', :foreign_key => 'historiaNaturalId'

end
