class Comentario < ActiveRecord::Base
  self.table_name = :comentarios

  validates :comentario, :presence => true
  validates :especie_id, :presence => true
end
