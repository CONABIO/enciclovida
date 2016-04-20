class CategoriaConteo < ActiveRecord::Base

  self.table_name='categorias_conteo'
  belongs_to :especie
end