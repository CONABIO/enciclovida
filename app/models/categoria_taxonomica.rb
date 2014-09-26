class CategoriaTaxonomica < ActiveRecord::Base
  self.table_name = 'categorias_taxonomicas'
  self.primary_key = 'id'
  has_many :especies

  scope :cat_taxonom, ->(valor) { find(valor).nombre_categoria_taxonomica }
end
