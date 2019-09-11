class Fichas::Observacionescarac < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.observacionescarac"
	self.primary_key = [:especieId, :idpregunta]

  belongs_to :taxon, class_name: 'Fichas::Taxon', :foreign_key => 'especieId'

	PREGUNTAS = {
			:ambi_especies_asociadas => 2,
      :ambi_vegetacion_esp_mundo => 3,
			:ambi_info_clima => 4,
      :ambi_info_clima_exotico => 5,
			:infotiposuelo => 6,
			:ambi_infogeoforma => 7,
			:infoalimentacion => 9,
			:infoaddforrajeo => 8,
			:infoaddhabito => 12,
			:infosistaparea => 13,
			:infocrianza => 14,
			:infodisp => 15,
			:infostruct => 16,
			:infointer => 17,
			:infocons => 26,
      :info_ecorregiones => 52,
			# OPCIONES PARA LAS INVASORAS Y SECCION 11 OCULTA (QUE YA EXISTE TABLA PARA ESO PERO NI IDEA.....)
			:rutasintro => 32,
			:mecanismoimpacto => 33,
			:efectoimpacto => 34,
			:intensidadimpacto => 35,
			:naturalizacion => 36,
			:especiesasociadas => 37,
			:plasticidad => 38,
			:dispersion => 39,
			:platencia => 40,
			:seguridad => 41,
			:enfermedadesei => 42,
			:infoarresp => 46,
			:infoAP => 48,
      :edopoblacion => 52,
      :persistenciapob => 53,
      :abundanciapob => 54,
      :historiaintro => 55,
      :otrossitios => 56,
      :adahabitat => 57,
      :adaclima => 58,
      :congeneres => 59,
      :frecintro => 61,
      :impactosei => 62,
      :impactobio => 63,
      :impactoeco => 64,
      :impactoinfra => 65,
      :impactosocial => 66,
      :impactootros => 67,
      :prevencion => 71,
      :manejocontrol => 72,
      :erradicacion => 73,
      :cuarentena => 74,
      :susceptibilidad => 75,
      :controlbiol => 76,
      :regulacion => 77,
      :benecologicos => 78,
      :beneconomicos => 79,
      :bensociales => 80,
      :conclimatica => 81,
      :conecologica => 82,
      :plasconductual => 85,
      :plasrepro => 86,
      :hibridacion => 87,
      :crecimientosei => 90,
      :spequivalentes => 92,
      :cca => 93,
      :fisk => 94,
      :fiisk => 95,
      :mfisk => 96,
      :miisk => 97,
      :aisk => 98,
      :tiisk => 99,
      :pier => 100,
      :meri => 101,
      :otroar => 102
	}
end











































=begin
$sql = "SELECT * FROM observacionescarac WHERE especieId"

:infotiposuelo => 6,
:infogeoforma => 7,
:infoalimenta => 9,
:infoaddforrajeo => 8,
:infoaddhabito => 12,
:infosistaparea => 13,
:infocrianza => 14,
:infodisp => 15,
:infostruct => 16,
:infointer => 17,
:infocons => 26,
:rutasintro => 32,
:mecanismoimpacto => 33,
:efectoimpacto => 34,
:intensidadimpacto => 35,
:naturalizacion => 36,
:especiesasociadas => 37,
:plasticidad => 38,
:dispersion => 39,
:platencia => 40,
:seguridad => 41,
:enfermedadesei => 42,
:infoarresp => 46,
:infoAP => 48,
=end