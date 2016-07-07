class Comentario < ActiveRecord::Base
  self.table_name = :comentarios

  belongs_to :especie
  belongs_to :usuario
  belongs_to :categoria_comentario, :class_name => 'CategoriaComentario', :foreign_key => 'categoria_comentario_id', :dependent => :destroy

  validates :comentario, :presence => true
  validates :especie_id, :presence => true

  has_ancestry

  # Atributo para tener la cuenta de los comentarios del historial
  attr_reader :cuantos
  attr_writer :cuantos

  # Para evitar el google captcha a los usuarios administradores
  attr_reader :con_verificacion
  attr_writer :con_verificacion

  # Para saber si es un comentario de un administrador
  attr_reader :es_admin
  attr_writer :es_admin

  # Para saber si es una respuesta del usuario
  attr_reader :es_respuesta
  attr_writer :es_respuesta

  # Para tener la referencia al nombre de la especie
  attr_reader :nombre_cientifico
  attr_writer :nombre_cientifico

  # Para tener la referencia al nombre comun de la especie
  attr_reader :nombre_comun
  attr_writer :nombre_comun

  validates_presence_of :categoria_comentario_id
  before_save :id_a_base_32


  def self.options_for_select
    [['No público y pendiente',1],['Público y pendiente',2],['Público y resuelto',3],['No público y resuelto',4],['Eliminar',5]]
  end

  def id_a_base_32
    return true unless self.new_record?

    c = Comentario.select('id').limit(1).order('created_at DESC').first
    id_base_10 = c.id.to_i(32)
    id_incremento = id_base_10 + 1
    self.id = id_incremento.to_s(32)
  end

  def completa_nombre_correo_especie
    if u = usuario
      self.nombre = "#{u.nombre} #{u.apellido}"
      self.correo = u.email
    end

    if t = especie
      self.nombre_cientifico = t.nombre_cientifico

      if a = t.adicional
        self.nombre_comun = a.nombre_comun_principal
      end
    end

  end
end
