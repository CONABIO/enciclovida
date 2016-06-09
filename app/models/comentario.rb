class Comentario < ActiveRecord::Base
  self.table_name = :comentarios

  belongs_to :especie
  belongs_to :usuario

  validates :comentario, :presence => true
  validates :especie_id, :presence => true

  has_ancestry

  # Atributo para tener la cuenta de los comentarios del historial
  attr_reader :cuantos
  attr_writer :cuantos
end
