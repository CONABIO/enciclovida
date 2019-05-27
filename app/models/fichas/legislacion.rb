class Fichas::Legislacion < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.legislacion"
	self.primary_keys = :legislacionId,  :especieId

	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId'

	# Legislaciones existentes
  TIPOS_LEGISLACIONES = [
      "NOM-059-SEMARNAT-2001",
      "NOM-059-SEMARNAT",
      "UICN",
      "CITES"
  ]

  L_SEMARNAT = [
      'Probablemente extinta en medio silvestre (E)'.to_sym,
      'En peligro de extinción (P)'.to_sym,
      'Amenazadas (A)'.to_sym,
      'Sujetas a protección especial (Pr)'.to_sym,
      'No evaluada (NE)'.to_sym
  ]

  L_UICN = [
      'Extinto (EX extinct)'.to_sym,
      'Extinto en estado silvestre (EW extinct in the wild)'.to_sym,
      'En peligro crítico (CR critically endangered)'.to_sym,
      'En peligro (EN endangered)'.to_sym,
      'Vulnerable (VU vulnerable)'.to_sym,
      'Casi amenazado (NT near threatened)'.to_sym,
      'Preocupación menor (LC least concern)'.to_sym,
      'Datos insuficientes (DD data deficient)'.to_sym,
      'No evaluado (NE not evaluated)'.to_sym
  ]

  L_CITES = [
      'Apéndice I'.to_sym,
      'Apéndice II'.to_sym,
      'Apéndice III'.to_sym,
      'No listada'.to_sym
  ]

	def existe_legislacion(lista, num)
		lista.each do |a|
			if a.nombreLegislacion == Fichas::Legislacion::TIPOS_LEGISLACIONES[num]
				return a
			end
		end
  end

end
