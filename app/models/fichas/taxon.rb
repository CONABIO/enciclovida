class Fichas::Taxon < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.taxon"
	self.primary_key = 'especieId'

	has_one :scat, class_name: 'Scat', primary_key: :IdCAT, foreign_key: Scat.attribute_alias(:catalogo_id)
	has_one :especie, through: :scat, source: :especie
	has_one :habitats, class_name: 'Fichas::Habitat', :foreign_key => 'especieId', inverse_of: :taxon



	has_many :caracteristicas, :class_name => 'Fichas::Caracteristicasespecie', :foreign_key => :especieId, inverse_of: :taxon
  has_many :t_climas, through: :caracteristicas


	accepts_nested_attributes_for :caracteristicas, allow_destroy: true, reject_if: :all_blank




	# Preguntas de información adicional y observaciones en la tabla Observacionescarac
	has_many :ambi_info_ecorregiones,-> {where('observacionescarac.idpregunta = ?', Fichas::Observacionescarac::PREGUNTAS[:info_ecorregiones])}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :ambi_especies_asociadas,-> {where('observacionescarac.idpregunta = ?', Fichas::Observacionescarac::PREGUNTAS[:ambi_especies_asociadas])}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :ambi_vegetacion_esp_mundo,-> {where('observacionescarac.idpregunta = ?', Fichas::Observacionescarac::PREGUNTAS[:ambi_vegetacion_esp_mundo])}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :ambi_info_clima_exotico,-> {where('observacionescarac.idpregunta = ?', Fichas::Observacionescarac::PREGUNTAS[:ambi_info_clima_exotico])}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon

	has_many :infotiposuelo,-> {where('observacionescarac.idpregunta = ?', 6 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :infogeoforma,-> {where('observacionescarac.idpregunta = ?', 7 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :infoalimenta,-> {where('observacionescarac.idpregunta = ?', 9 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :infoaddforrajeo,-> {where('observacionescarac.idpregunta = ?', 8 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :infoaddhabito,-> {where('observacionescarac.idpregunta = ?', 12 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :infosistaparea,-> {where('observacionescarac.idpregunta = ?', 13 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :infocrianza,-> {where('observacionescarac.idpregunta = ?', 14 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :infodisp,-> {where('observacionescarac.idpregunta = ?', 15 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :infostruct,-> {where('observacionescarac.idpregunta = ?', 16 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :infointer,-> {where('observacionescarac.idpregunta = ?', 17 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :infocons,-> {where('observacionescarac.idpregunta = ?', 26 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :rutasintro,-> {where('observacionescarac.idpregunta = ?', 32 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :mecanismoimpacto,-> {where('observacionescarac.idpregunta = ?', 33 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :efectoimpacto,-> {where('observacionescarac.idpregunta = ?', 34 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :intensidadimpacto,-> {where('observacionescarac.idpregunta = ?', 35 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :naturalizacion,-> {where('observacionescarac.idpregunta = ?', 36 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :especiesasociadas,-> {where('observacionescarac.idpregunta = ?', 37 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :plasticidad,-> {where('observacionescarac.idpregunta = ?', 38 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :dispersion,-> {where('observacionescarac.idpregunta = ?', 39 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :platencia,-> {where('observacionescarac.idpregunta = ?', 40 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :seguridad,-> {where('observacionescarac.idpregunta = ?', 41 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :enfermedadesei,-> {where('observacionescarac.idpregunta = ?', 42 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :infoarresp,-> {where('observacionescarac.idpregunta = ?', 46 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :infoAP,-> {where('observacionescarac.idpregunta = ?', 48 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon




	# Acceso desde Cocoon
	accepts_nested_attributes_for :ambi_info_ecorregiones, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :ambi_especies_asociadas, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :ambi_vegetacion_esp_mundo, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :ambi_info_clima_exotico, allow_destroy: true, reject_if: :all_blank










	# - - - - -
	has_many :distribuciones, :class_name => 'Fichas::Distribucion', :foreign_key => 'especieId', inverse_of: :taxon
	has_many :caracteristicasEspecies, :class_name => 'Fichas::Caracteristicasespecie', :foreign_key => 'especieId'
	has_many :conservacion, :class_name => 'Fichas::Conservacion', :foreign_key => 'especieId'
	has_many :demografiaAmenazas, :class_name=> 'Fichas::Demografiaamenazas', :foreign_key => 'especieId'
  has_many :endemicas, :class_name => 'Fichas::Endemica', :foreign_key => 'especieId'
	has_one :historiaNatural, class_name: 'Fichas::Historianatural', :foreign_key => 'especieId'
  has_one :invasividad, class_name: 'Fichas::Invasividad', :foreign_key => 'especieId'
	has_many :legislaciones, class_name: 'Fichas::Legislacion', :foreign_key => 'especieId'
	has_many :metadatos, class_name: 'Fichas::Metadatos', :foreign_key => 'especieId'
	has_one :nombreComun, class_name: 'Fichas::Nombrecomun', :foreign_key => 'especieId'
	has_many :productoComercios, class_name: 'Fichas::Productocomercio', :foreign_key => 'especieId'
	has_many :sinonimos , class_name: 'Fichas::Sinonimo', :foreign_key => 'especieId'
	has_many :referenciasBibliograficas, class_name: 'Fichas::Referenciabibliografica', :foreign_key => 'especieId'









	accepts_nested_attributes_for :invasividad, allow_destroy: true
	accepts_nested_attributes_for :caracteristicasEspecies, allow_destroy: true
	accepts_nested_attributes_for :conservacion, allow_destroy: true
	accepts_nested_attributes_for :demografiaAmenazas, allow_destroy: true
	accepts_nested_attributes_for :distribuciones, allow_destroy: true
	accepts_nested_attributes_for :endemicas, allow_destroy: true
	accepts_nested_attributes_for :habitats, allow_destroy: true
	accepts_nested_attributes_for :historiaNatural, allow_destroy: true
  accepts_nested_attributes_for :legislaciones, reject_if: :all_blank, allow_destroy: true
	accepts_nested_attributes_for :metadatos, allow_destroy: true
	accepts_nested_attributes_for :productoComercios, allow_destroy: true
	accepts_nested_attributes_for :referenciasBibliograficas, allow_destroy: true








	# reject_if: proc { |attributes| attributes['name'].blank? }


	# Sección I: Clasificacion
	ORIGEN_MEXICO = [
			"Exótica/No nativa".to_sym,
			"Nativa".to_sym,
			"Criptogénica".to_sym
	]

	MEDIDA_LONGEVIDAD = [
			"Años".to_sym,
			"Meses".to_sym,
			"Dias".to_sym
	]

  TIPOS_FICHA = [
		"CITES".to_sym,
		"Invasora".to_sym,
		"Silvestre".to_sym,
		"Prioritaria".to_sym
  ]

  PRESENCIA = [
      "Ausencia/Ausente".to_sym,
      "Presente".to_sym,
      "Presentes por confirmar (casual)".to_sym,
      "Presente confinado".to_sym,
      "Se desconoce".to_sym
  ]

	# Para sección de especies prioritarias
	ESPECIE_ENLISTADA = [:yes, :no]
	LISTADOS = [:DOF, :CONABIO]
	PRIORIDADS = [:alta, :media, :baja]

  # Devuelve las secciones que tienen información
	def dame_edad_peso_largo
		datos = {}
		datos[:estatus] = false

		if edadinicialmachos.present? || edadfinalmachos.present? || edadinicialhembras.present? || edadfinalhembras.present?
			datos[:edad] = true
			datos[:estatus] = true
		end

		if pesoinicialmachos.present? || pesofinalmachos.present? || pesoinicialhembras.present? || pesofinalhembras.present?
			datos[:peso] = true
			datos[:estatus] = true unless datos[:estatus]
		end

		if largoinicialmachos.present? || largofinalmachos.present? || largoinicialhembras.present? || largofinalhembras.present?
			datos[:largo] = true
			datos[:estatus] = true unless datos[:estatus]
		end

		datos
	end

end