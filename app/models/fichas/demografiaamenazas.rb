class Fichas::Demografiaamenazas < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.demografiaamenazas"
	self.primary_key = :demografiaAmenazasId#,  :especieId

	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId'

  has_one :interaccion, :class_name => 'Fichas::Interaccion', :foreign_key => 'interaccionId'
	has_many :relDemografiasAmenazas, class_name: 'Fichas::Reldemografiaamenazas', :foreign_key => 'demografiaAmenazasId'
  has_many :amenazaDirecta, class_name: 'Fichas::Amenazadirecta', through: :relDemografiasAmenazas

  accepts_nested_attributes_for :interaccion, allow_destroy: true
	accepts_nested_attributes_for :amenazaDirecta, allow_destroy: true

	PATRON_OCUPACION = [
			"Agregada".to_sym,
			"Uniforme".to_sym,
			"Al azar".to_sym
  ]

  TENDENCIA_POBLACIONAL = [
			'Estable'.to_sym,
			'Aumenta'.to_sym,
			'Decrece'.to_sym,
			'ND'.to_sym,
			'NA'.to_sym
	]

  ORGANIZACION_SOCIAL = [
			"Colonias".to_sym,
			"Familia".to_sym,
			"Grupo".to_sym,
			"Manadas".to_sym,
			"Solitarios".to_sym,
			"Cardúmenes".to_sym,
			"Eusocial".to_sym,
			"Filopatría-machos".to_sym,
			"Filopatría-hembras".to_sym,
			"Quasisocial".to_sym,
			"Semisocial".to_sym
  ]

end