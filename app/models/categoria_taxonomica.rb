class CategoriaTaxonomica < ActiveRecord::Base

  self.table_name = 'categorias_taxonomicas'
  has_many :especies

  scope :cat_taxonom, ->(valor) { find(valor).nombre_categoria_taxonomica }

end
