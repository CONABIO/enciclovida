class Admin::EspecieCatalogo < EspecieCatalogo

  #has_many :especies, class_name: Admin::Especie, foreign_key: attribute_alias(:especie_id)
  belongs_to :especie, foreign_key: attribute_alias(:especie_id)
  belongs_to :catalogo, foreign_key: attribute_alias(:catalogo_id)
  has_many :bibliografias_catalogo, class_name: 'Admin::EspecieCatalogoBibliografia', primary_key: attribute_alias(:catalogo_id), foreign_key: attribute_alias(:catalogo_id)
  has_many :bibliografias_especie, class_name: 'Admin::EspecieCatalogoBibliografia', primary_key: attribute_alias(:especie_id), foreign_key: attribute_alias(:especie_id)
  has_many :bibliografias, class_name: 'Admin::EspecieCatalogoBibliografia', primary_key: [attribute_alias(:especie_id),attribute_alias(:catalogo_id)], foreign_key: [attribute_alias(:especie_id),attribute_alias(:catalogo_id)]
  #has_many :bibliografias, through: :bibliografias_totales, source: :bibliografias

  attr_accessor :nombre_cientifico
  accepts_nested_attributes_for :bibliografias, reject_if: :all_blank, allow_destroy: true

end
