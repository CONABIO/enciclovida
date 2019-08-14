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
			:info_ecorregiones => 52
	}
end


=begin
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