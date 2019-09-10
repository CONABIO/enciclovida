class Fichas::Taxon < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.taxon"
	self.primary_key = 'especieId'

	has_one :scat, class_name: 'Scat', primary_key: :IdCAT, foreign_key: Scat.attribute_alias(:catalogo_id)
	has_one :especie, through: :scat, source: :especie

	has_one :habitats, class_name: 'Fichas::Habitat', :foreign_key => 'especieId', inverse_of: :taxon
	has_many :endemicas, :class_name => 'Fichas::Endemica', :foreign_key => 'especieId', inverse_of: :taxon
	has_one :distribuciones, :class_name => 'Fichas::Distribucion', :foreign_key => 'especieId', inverse_of: :taxon
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

	# - - - - - -   Características sobre cierta especie ( OPCIONES MULTIPLES ) - - - - - - #
	# A partir de aquí se obtienen las carácterísticas:
	has_many :caracteristicas, :class_name => 'Fichas::Caracteristicasespecie', :foreign_key => :especieId, inverse_of: :taxon
	has_many :opciones_preguntas, through: :caracteristicas

	# - - - - - -   Preguntas de observaciones en la tabla Observacionescarac ( DE HABITAT) - - - - - - #
	has_many :ambi_info_ecorregiones,-> {where('observacionescarac.idpregunta = ?', 52)}, class_name: 'Fichas::Observacionescarac',  foreign_key: :especieId, inverse_of: :taxon
	has_many :ambi_especies_asociadas,-> {where('observacionescarac.idpregunta = ?', 2)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :ambi_vegetacion_esp_mundo,-> {where('observacionescarac.idpregunta = ?', 3)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :ambi_info_clima,-> {where('observacionescarac.idpregunta = ?', 4)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :ambi_info_clima_exotico,-> {where('observacionescarac.idpregunta = ?', 5)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :ambi_infotiposuelo,-> {where('observacionescarac.idpregunta = ?', 6 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :ambi_infogeoforma,-> {where('observacionescarac.idpregunta = ?', 7 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon

	# - - - - - -   Preguntas de observaciones en la tabla Observacionescarac ( DE HISTORIA NATURAL ) - - - - - - #
	# De biología
	has_many :infoaddforrajeo,-> {where('observacionescarac.idpregunta = ?', 8 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :infoalimenta,-> {where('observacionescarac.idpregunta = ?', 9)}, class_name: 'Fichas::Observacionescarac',  foreign_key: :especieId, inverse_of: :taxon
	has_many :infoaddhabito,-> {where('observacionescarac.idpregunta = ?', 12 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :infodisp,-> {where('observacionescarac.idpregunta = ?', 15 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :infostruct,-> {where('observacionescarac.idpregunta = ?', 16 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	# De rep. animal
	has_many :infosistaparea,-> {where('observacionescarac.idpregunta = ?', 13 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :infocrianza,-> {where('observacionescarac.idpregunta = ?', 14 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	# De rep. vegetal
	has_many :infoarresp,-> {where('observacionescarac.idpregunta = ?', 46 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon
	has_many :infoAP,-> {where('observacionescarac.idpregunta = ?', 48 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon

	# - - - - - -   Preguntas de observaciones en la tabla Observacionescarac ( DE DEMOGRAFIAAMENAZAS ) - - - - - - #
	has_many :infointer,-> {where('observacionescarac.idpregunta = ?', 17 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon

	# - - - - - -   Preguntas de observaciones en la tabla Observacionescarac ( De Conservación ) - - - - - - #
	has_many :infocons,-> {where('observacionescarac.idpregunta = ?', 26 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, inverse_of: :taxon

	# Acceso desde cocoon
	accepts_nested_attributes_for :ambi_info_ecorregiones, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :ambi_especies_asociadas, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :ambi_vegetacion_esp_mundo, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :ambi_info_clima, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :ambi_info_clima_exotico, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :ambi_infotiposuelo, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :ambi_infogeoforma, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }

	accepts_nested_attributes_for :infoAP, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :infoarresp, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :infoalimenta, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :infoaddforrajeo, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :infoaddhabito, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :infosistaparea, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :infocrianza, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :infodisp, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :infostruct, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }

	accepts_nested_attributes_for :infointer, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }

	accepts_nested_attributes_for :infocons, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }

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
	accepts_nested_attributes_for :caracteristicas, allow_destroy: true, reject_if: :all_blank

	# - - - - - -   Preguntas de observaciones en la tabla Observacionescarac ( INFORMACIÓN ADICIONAL EN SU MAYORÍA ) - - - - - - #
	#Preguntas para invasoras
	has_many :mecanismoimpacto,-> {where('observacionescarac.idpregunta = ?', 33 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :efectoimpacto,-> {where('observacionescarac.idpregunta = ?', 34 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :intensidadimpacto,-> {where('observacionescarac.idpregunta = ?', 35 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :naturalizacion,-> {where('observacionescarac.idpregunta = ?', 36 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :especiesasociadas,-> {where('observacionescarac.idpregunta = ?', 37 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :plasticidad,-> {where('observacionescarac.idpregunta = ?', 38 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :platencia,-> {where('observacionescarac.idpregunta = ?', 40 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :seguridad,-> {where('observacionescarac.idpregunta = ?', 41 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :enfermedadesei,-> {where('observacionescarac.idpregunta = ?', 42 )}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :edopoblacion,-> {where('observacionescarac.idpregunta = ?', 52)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :persistenciapob,-> {where('observacionescarac.idpregunta = ?', 53)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :abundanciapob,-> {where('observacionescarac.idpregunta = ?', 54)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :historiaintro,-> {where('observacionescarac.idpregunta = ?', 55)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :otrossitios,-> {where('observacionescarac.idpregunta = ?', 56)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :adahabitat,-> {where('observacionescarac.idpregunta = ?', 57)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :adaclima,-> {where('observacionescarac.idpregunta = ?', 58)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :congeneres,-> {where('observacionescarac.idpregunta = ?', 59)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :frecintro,-> {where('observacionescarac.idpregunta = ?', 61)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :impactosei,-> {where('observacionescarac.idpregunta = ?', 62)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :impactobio,-> {where('observacionescarac.idpregunta = ?', 63)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :impactoeco,-> {where('observacionescarac.idpregunta = ?', 64)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :impactoinfra,-> {where('observacionescarac.idpregunta = ?', 65)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :impactosocial,-> {where('observacionescarac.idpregunta = ?', 66)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :impactootros,-> {where('observacionescarac.idpregunta = ?', 67)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :prevencion,-> {where('observacionescarac.idpregunta = ?', 71)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :manejocontrol,-> {where('observacionescarac.idpregunta = ?', 72)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :erradicacion,-> {where('observacionescarac.idpregunta = ?', 73)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :cuarentena,-> {where('observacionescarac.idpregunta = ?', 74)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :susceptibilidad,-> {where('observacionescarac.idpregunta = ?', 75)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :controlbiol,-> {where('observacionescarac.idpregunta = ?', 76)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :regulacion,-> {where('observacionescarac.idpregunta = ?', 77)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :benecologicos,-> {where('observacionescarac.idpregunta = ?', 78)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :beneconomicos,-> {where('observacionescarac.idpregunta = ?', 79)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :bensociales,-> {where('observacionescarac.idpregunta = ?', 80)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :conclimatica,-> {where('observacionescarac.idpregunta = ?', 81)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :conecologica,-> {where('observacionescarac.idpregunta = ?', 82)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :plasconductual,-> {where('observacionescarac.idpregunta = ?', 85)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :plasrepro,-> {where('observacionescarac.idpregunta = ?', 86)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :hibridacion,-> {where('observacionescarac.idpregunta = ?', 87)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :crecimientosei,-> {where('observacionescarac.idpregunta = ?', 90)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :spequivalentes,-> {where('observacionescarac.idpregunta = ?', 92)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :cca,-> {where('observacionescarac.idpregunta = ?', 93)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :fisk,-> {where('observacionescarac.idpregunta = ?', 94)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :fiisk,-> {where('observacionescarac.idpregunta = ?', 95)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :mfisk,-> {where('observacionescarac.idpregunta = ?', 96)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :miisk,-> {where('observacionescarac.idpregunta = ?', 97)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :aisk,-> {where('observacionescarac.idpregunta = ?', 98)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :tiisk,-> {where('observacionescarac.idpregunta = ?', 99)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :pier,-> {where('observacionescarac.idpregunta = ?', 100)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :meri,-> {where('observacionescarac.idpregunta = ?', 101)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon
	has_many :otroar,-> {where('observacionescarac.idpregunta = ?', 102)}, class_name: 'Fichas::Observacionescarac', foreign_key: :especieId, primary_key: :especieId, inverse_of: :taxon


	# Acceso desde Cocoon
	# INVASORAS
	accepts_nested_attributes_for :edopoblacion, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :persistenciapob, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :abundanciapob, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :historiaintro, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :otrossitios, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :adahabitat, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :adaclima, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :congeneres, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :frecintro, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :impactosei, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :impactobio, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :impactoeco, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :impactoinfra, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :impactosocial, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :impactootros, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :prevencion, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :manejocontrol, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :erradicacion, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :cuarentena, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :susceptibilidad, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :controlbiol, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :regulacion, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :benecologicos, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :beneconomicos, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :bensociales, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :conclimatica, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :conecologica, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :plasconductual, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :plasrepro, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :hibridacion, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :crecimientosei, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :spequivalentes, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :cca, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :fisk, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :fiisk, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :mfisk, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :miisk, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :aisk, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :tiisk, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :pier, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :meri, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :otroar, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :naturalizacion, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :mecanismoimpacto, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :efectoimpacto, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :intensidadimpacto, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :especiesasociadas, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :plasticidad, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :platencia, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :seguridad, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }
	accepts_nested_attributes_for :enfermedadesei, allow_destroy: true, reject_if: proc { |attributes| attributes[:infoadicional].blank? }

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