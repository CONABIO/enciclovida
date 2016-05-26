class Comentario < ActiveRecord::Base
  self.table_name = :comentarios

  belongs_to :especie
  belongs_to :usuario

  validates :comentario, :presence => true
  validates :especie_id, :presence => true
end
