class CategoriaTaxonomica < ActiveRecord::Base

  self.table_name = 'categorias_taxonomicas'
  has_many :especies

end
