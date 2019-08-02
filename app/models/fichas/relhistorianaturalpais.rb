class Fichas::Relhistorianaturalpais < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.relhistorianaturalpais"
	self.primary_keys = :historiaNaturalId,  :paisId

	belongs_to :historiaNatural, :class_name => 'Fichas::Historianatural', :foreign_key => 'historiaNaturalId'
	belongs_to :pais_importacion, :class_name => 'Fichas::Pais', :foreign_key => 'paisId', :primary_key => :paisId

end
