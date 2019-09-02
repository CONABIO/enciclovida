class Fichas::Taxon < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.taxon"
	self.primary_key = 'especieId'

	has_one :scat, class_name: 'Scat', primary_key: :IdCAT, foreign_key: Scat.attribute_alias(:catalogo_id)
	has_one :especie, through: :scat, source: :especie

	has_one :habitats, class_name: 'Fichas::Habitat', :foreign_key => 'especieId', inverse_of: :taxon
	has_many :endemicas, :class_name => 'Fichas::Endemica', :foreign_key => 'especieId', inverse_of: :taxon
	has_many :distribuciones, :class_name => 'Fichas::Distribucion', :foreign_key => 'especieId', inverse_of: :taxon
	has_one :historiaNatural, class_name: 'Fichas::Historianatural', :foreign_key => 'especieId', inverse_of: :taxon
	has_one :demografiaAmenazas, :class_name=> 'Fichas::Demografiaamenazas', :foreign_key => 'especieId', inverse_of: :taxon
	has_many :productocomercio_nal,-> {where('nacionalinternacional = "nacional"')}, class_name: 'Fichas::Productocomercio', :foreign_key => 'especieId', inverse_of: :taxon
	has_many :productocomercio_inter,-> {where('nacionalinternacional = "internacional"')}, class_name: 'Fichas::Productocomercio', :foreign_key => 'especieId', inverse_of: :taxon
	has_many :referenciasBibliograficas, class_name: 'Fichas::Referenciabibliografica', :foreign_key => 'especieId', inverse_of: :taxon
	has_many :legislaciones, class_name: 'Fichas::Legislacion', :foreign_key => 'especieId', inverse_of: :taxon
	has_many :conservacion, :class_name => 'Fichas::Conservacion', :foreign_key => 'especieId', inverse_of: :taxon
	has_one :invasividad, class_name: 'Fichas::Invasividad', :foreign_key => 'especieId', inverse_of: :taxon
	has_many :metadatos, class_name: 'Fichas::Metadatos', :foreign_key => 'especieId', inverse_of: :taxon
	has_many :distribucion_historica, class_name: 'Fichas::Distribucionhistorica', :foreign_key => "especieId", inverse_of: :taxon

	# No utilizadas
	has_many :sinonimos , class_name: 'Fichas::Sinonimo', :foreign_key => 'especieId', inverse_of: :taxon
	has_one :nombreComun, class_name: 'Fichas::Nombrecomun', :foreign_key => 'especieId', inverse_of: :taxon


	accepts_nested_attributes_for :habitats, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :distribuciones, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :endemicas, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :historiaNatural, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :demografiaAmenazas, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :productocomercio_nal, reject_if: :all_blank, allow_destroy: true
	accepts_nested_attributes_for :productocomercio_inter, reject_if: :all_blank, allow_destroy: true
	accepts_nested_attributes_for :legislaciones, reject_if: :all_blank, allow_destroy: true
	accepts_nested_attributes_for :referenciasBibliograficas, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :conservacion, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :invasividad, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :metadatos, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :distribucion_historica, allow_destroy: true


	# - - - - - -   Características sobre cierta especie ( OPCIONES MULTIPLES ) - - - - - - #
	# A partir de aquí se obtienen las carácterísticas:
	has_many :caracteristicas, :class_name => 'Fichas::Caracteristicasespecie', :foreign_key => :especieId, inverse_of: :taxon
  has_many :opciones_preguntas, through: :caracteristicas

	# Acceso desde cocoon
	accepts_nested_attributes_for :caracteristicas, allow_destroy: true, reject_if: :all_blank


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



=begin :: BASURA ::

	# DESDE HISTORIA NATURAL:
	has_many :t_habitoPlantas, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_habitoPlantas, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_alimentacion, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_forrajeo, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_migracion, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_tipo_migracion, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_habito, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_tipodispersion, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_structdisp, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_dispersionsei, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_comnalsel, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_proposito_com, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_comintersel, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_proposito_com_int, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas

	# Para T ANIMAL
	has_many :t_sistapareamiento, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_sitioanidacion, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas

	# Para T VEGETAL
	has_many :t_arregloespacialflores, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_arregloespacialindividuos, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_arregloespacialpoblaciones, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_vectorespolinizacion, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_agentespolinizacion, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_arregloespacial, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas

	# MOSTRADAS EN HABITATS
  has_many :t_climas, through: :caracteristicas
	has_many :t_climaexo, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_tipoVegetacionSecundaria, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_tipovegetmundial, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_suelo, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_geoforma, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_habitatAntropico, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_ecorregionMarinaN1, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_zonaVida, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas

	# DESDE CONSERVACION
	has_many :t_esquemamanejo, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_tipopesca, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_regioncaptura, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas

	# DESDE DEMOGRAFIA
	has_many :t_interacciones, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas

	# DESDE INVASORAS
	has_many :t_naturalizacionsei, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_mecanismos, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_efectoimpactosei, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_intensidadimpactosei, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_especiesasociadassei, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_plasticidadsei, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_platenciasei, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_seguridadsei, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas
	has_many :t_enfermedadessei, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicas


	accepts_nested_attributes_for :t_climas, allow_destroy: true
	accepts_nested_attributes_for :t_climaexo, allow_destroy: true
	accepts_nested_attributes_for :t_tipoVegetacionSecundaria, allow_destroy: true
	accepts_nested_attributes_for :t_tipovegetmundial, allow_destroy: true
	accepts_nested_attributes_for :t_suelo, allow_destroy: true
	accepts_nested_attributes_for :t_geoforma, allow_destroy: true
	accepts_nested_attributes_for :t_habitatAntropico, allow_destroy: true
	accepts_nested_attributes_for :t_ecorregionMarinaN1, allow_destroy: true
	accepts_nested_attributes_for :t_zonaVida, allow_destroy: true

	accepts_nested_attributes_for :t_esquemamanejo, allow_destroy: true
	accepts_nested_attributes_for :t_tipopesca, allow_destroy: true
	accepts_nested_attributes_for :t_regioncaptura, allow_destroy: true
=end