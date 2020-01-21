class Admin::Bibliografia < Bibliografia

  scope :autocompleta, ->(termino) { select(:id, :cita_completa).where("#{Bibliografia.attribute_alias(:cita_completa)} REGEXP ?", termino).limit(10) }

end
