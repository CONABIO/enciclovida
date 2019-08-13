class Fichas::Observacionescarac < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.observacionescarac"
	self.primary_keys = :especieId, :idpregunta

  belongs_to :taxon, class_name: 'Fichas::Taxon', :foreign_key => 'especieId'
  
	PREGUNTAS = {
			:ambi_especies_asociadas => 2,
      :ambi_vegetacion_esp_mundo => 3,
			:ambi_info_clima => 4,
      :ambi_info_clima_exotico => 5,
			:info_ecorregiones => 52
	}

end

ambi_info_clima

infotiposuelo 6
infogeoforma 7

infoalimenta 9

infoaddforrajeo 8

infoaddhabito 12

infosistaparea 13

Uaddinfocrianza 14

Uaddinfodisp 15


16
Uaddinfostruct
17
Uaddinfointer
26
Uaddinfocons
32
Urutasintro
33
Umecanismoimpacto
34
Uefectoimpacto
35
Uintensidadimpacto
36
Unaturalizacion
37
Uespeciesasociadas
38
Uplasticidad
39
Udispersion
40
Uplatencia
41
Useguridad
42
Uenfermedadesei
46
Uaddinfoarresp
48
UaddinfoAP