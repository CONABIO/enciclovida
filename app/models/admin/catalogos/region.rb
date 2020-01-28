class Admin::Region < Region

  scope :autocompleta, ->(termino) { select(:id, :nombre_region).where("#{Region.attribute_alias(:nombre_region)} REGEXP ?", termino).limit(10) }

end
