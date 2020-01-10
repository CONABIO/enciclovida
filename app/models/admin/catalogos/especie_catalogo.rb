class Admin::EspecieCatalogo < EspecieCatalogo

  #has_many :especies, class_name: Admin::Especie, foreign_key: attribute_alias(:especie_id)
  belongs_to :especie, foreign_key: attribute_alias(:especie_id)
  belongs_to :catalogo, foreign_key: attribute_alias(:catalogo_id)
  has_many :bibliografias, foreign_key: attribute_alias(:catalogo_id)

  attr_accessor :nombre_cientifico

    #accepts_nested_attributes_for :bibliografias, reject_if: :all_blank, allow_destroy: true

end
