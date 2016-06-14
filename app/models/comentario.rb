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

  # Para evitar el google captcha a los usuarios administradores
  attr_accessor :con_verificacion

  before_save :id_a_base_32

  def id_a_base_32
    return true unless self.new_record?

    c = Comentario.select('id').limit(1).order('created_at DESC').first
    id_base_10 = c.id.to_i(32)
    id_incremento = id_base_10 + 1
    self.id = id_incremento.to_s(32)
  end
end
