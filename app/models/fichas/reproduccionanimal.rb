class Fichas::Reproduccionanimal < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.reproduccionanimal"
	self.primary_key = 'reproduccionAnimalId'

	has_one :historiaNatural, class_name: 'Fichas::Historianatural', :foreign_key => 'reproduccionAnimalId'

	has_many :t_sistapareamiento, through: :historiaNatural
	has_many :t_sitioanidacion, through: :historiaNatural

  EVENTOS_REPROD = [
      'Iteróparo'.to_sym,
      'Semélparo'.to_sym
  ]

  TIPO_FECUNDACION = [
      "Interna".to_sym,
      "Externa".to_sym
  ]

  CUIDADO_PARENTAL = [
      "hembra".to_sym,
      "macho".to_sym,
      "ambos".to_sym
  ]

end
