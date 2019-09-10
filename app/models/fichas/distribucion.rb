class Fichas::Distribucion < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.distribucion"
	self.primary_keys = :distribucionId, :especieId

	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId'

	has_many :relDistribucionesPaises, class_name: 'Fichas::Reldistribucionpais', :foreign_key => "distribucionId"
	has_many :relDistribucionesEstados, class_name: 'Fichas::Reldistribucionestado', :foreign_key => "distribucionId", primary_key: :distribucionId
	has_many :relDistribucionesMunicipios, class_name: 'Fichas::Reldistribucionmunicipio', :foreign_key => "distribucionId"

	has_many :pais, class_name: 'Fichas::Pais', :through => :relDistribucionesPaises
	has_many :pais_inv, class_name: 'Fichas::Pais', :through => :relDistribucionesPaises
	has_many :pais_inv2, class_name: 'Fichas::Pais', :through => :relDistribucionesPaises
	has_many :estado, class_name: 'Fichas::Estado_F', :through => :relDistribucionesEstados
	has_many :municipio, class_name: 'Fichas::Municipio_F', :through => :relDistribucionesMunicipios


	accepts_nested_attributes_for :relDistribucionesPaises, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :relDistribucionesEstados, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :relDistribucionesMunicipios, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :pais, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :pais_inv, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :pais_inv2, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :estado, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :municipio, allow_destroy: true, reject_if: :all_blank

	DISTRIBUCINES = [
			'Muy restringida'.to_sym,
			'Restringida'.to_sym,
			'Medianamente restringida o amplia'.to_sym,
			'Ampliamente distribuidas o muy amplias'.to_sym
	]

	TIPO_DISTRIBUCION = [
			'Amplia'.to_sym,
			'Localizada'.to_sym,
			'Moderada'.to_sym,
			'Se desconoce'.to_sym
	]

end
