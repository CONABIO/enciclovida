class Admin::Region < Region

  establish_connection :admin
  scope :autocompleta, ->(termino) { select(:id, :nombre_region, :tipo_region_id).includes(:tipo_region).where("#{Region.attribute_alias(:nombre_region)} LIKE ? COLLATE utf8_general_ci", "%#{termino}%").limit(10) }

end
