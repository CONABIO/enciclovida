class Admin::EspecieCatalogo < EspecieCatalogo

  has_many :especies, class_name: Admin::Especie, foreign_key: attribute_alias(:especie_id)

end
