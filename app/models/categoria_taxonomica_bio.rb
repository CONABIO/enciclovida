class CategoriaTaxonomicaBio < CategoriaTaxonomica

  self.table_name = 'CategoriaTaxonomica'
  self.primary_key = 'IdCategoriaTaxonomica'

  alias_attribute :id, :IdCategoriaTaxonomica
  alias_attribute :nombre_categoria_taxonomica, :NombreCategoriaTaxonomica

  scope :cat_taxonom, ->(valor) { find(valor).nombre_categoria_taxonomica }
end
