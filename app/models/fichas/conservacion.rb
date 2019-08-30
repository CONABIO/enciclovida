class Fichas::Conservacion < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.conservacion"
	self.primary_keys = :conservacionId,  :especieId

	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId'
	has_one :cat_gruposEspecies, :class_name => 'Fichas::Cat_Gruposespecies', :foreign_key => 'Id'

	TIPO_VEDA = [
			'Permanente'.to_sym,
			'Permanente solo para pesca deportiva'.to_sym,
			'Temporal fija'.to_sym
	]
	TIPO_CAPTURA = [
		'Selectiva'.to_sym,
		'No selectiva'.to_sym
	]
end
