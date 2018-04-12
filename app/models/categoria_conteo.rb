class CategoriaConteo < ActiveRecord::Base

  establish_connection(:development)
  self.table_name='enciclovida.categorias_conteo'

  belongs_to :especie
end