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

  validates_presence_of :categoria_comentario_id
  before_save :id_a_base_32

  scope :join_especies,-> { joins('LEFT JOIN especies ON especies.id=comentarios.especie_id') }
  scope :join_adicionales,-> { joins('LEFT JOIN adicionales ON adicionales.especie_id=comentarios.especie_id') }
  scope :join_usuarios,-> { joins('LEFT JOIN usuarios u ON u.id=comentarios.usuario_id') }
  scope :join_usuarios2,-> { joins('LEFT JOIN usuarios u2 ON u2.id=comentarios.usuario_id2') }
  scope :select_basico,-> { select("comentarios.id, comentario, correo, comentarios.nombre as c_nombre, usuario_id, usuario_id2,
comentarios.especie_id, comentarios.ancestry, comentarios.created_at, comentarios.updated_at,
comentarios.estatus, fecha_estatus, categoria_comentario_id, comentarios.institucion AS c_institucion,
CONCAT(u.grado_academico,' ', u.nombre, ' ', u.apellido) AS u_nombre, u.email AS u_email,
u.institucion as u_institucion, nombre_cientifico, nombre_comun_principal, foto_principal,
CONCAT(u2.grado_academico,' ', u2.nombre, ' ', u2.apellido) AS u2_nombre") }
  scope :datos_basicos,-> { select_basico.join_usuarios.join_usuarios2.join_especies.join_adicionales }

  POR_PAGINA_PREDETERMINADO = 10

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

  def completa_nombre_correo
    if usuario_id.present?
      begin
        self.nombre = u_nombre
        self.correo = u_email
        self.institucion = u_institucion
      rescue  # Para las consultas que no viene con estos campos incluidos en el join
        u = usuario
        self.nombre = "#{u.grado_academico} #{u.nombre} #{u.apellido}".strip
        self.correo = u.email
        self.institucion = u.institucion
      end
    else
      begin
        self.nombre = self.c_nombre
        self.institucion = c_institucion
      end
    end
  end
end
