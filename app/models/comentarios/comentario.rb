class Comentario < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.ev}.comentarios"
  self.primary_key = 'id'

  belongs_to :especie
  belongs_to :usuario, optional: true
  belongs_to :usuario2, :class_name => 'Usuario', :foreign_key => 'usuario_id2', optional: true
  belongs_to :categorias_contenido, :class_name => 'CategoriasContenido', :foreign_key => 'categorias_contenido_id'

  has_ancestry

  has_one :general, :class_name => 'ComentarioGeneral', :foreign_key => 'comentario_id'
  has_one :comentario_proveedor, :class_name => 'ComentarioProveedor', :foreign_key => 'comentario_id'

  attr_accessor :cuantos, :con_verificacion, :es_admin, :es_respuesta, :es_propietario

  validates_presence_of :comentario
  validates_presence_of :especie_id
  validates_presence_of :categorias_contenido_id
  validates_presence_of :nombre, :if => :inicio_sesion?
  validates_format_of :correo, :with => Usuario::CORREO_REGEX, :message => Usuario::CORREO_INVALIDO_MSG, :if => :inicio_sesion?
  validates_length_of :correo, :within => 6..100, :if => :inicio_sesion?

  after_create :idABase32

  # Este scope de usuarios2 se queda porque hago dos joins a la misma tabla y necesito diferenciar los campos
  scope :join_usuarios2,-> { joins('LEFT JOIN usuarios u2 ON u2.id=comentarios.usuario_id2') }
  scope :select_basico,-> { select("comentarios.id, comentario, correo, comentarios.nombre as c_nombre, usuario_id, usuario_id2,
comentarios.especie_id, comentarios.ancestry, comentarios.created_at, comentarios.updated_at,
comentarios.estatus, fecha_estatus, categorias_contenido_id, comentarios.institucion AS c_institucion,
CONCAT(usuarios.nombre, ' ', usuarios.apellido) AS u_nombre, usuarios.email AS u_email,
usuarios.institucion AS u_institucion, #{Especie.table_name}.#{Especie.attribute_alias(:nombre_cientifico)} AS nombre_cientifico, nombre_comun_principal, foto_principal,
CONCAT(u2.nombre, ' ', u2.apellido) AS u2_nombre, #{Especie.table_name}.#{Especie.attribute_alias(:ancestry_ascendente_directo)} AS ancestry_ascendente_directo") }
  scope :datos_basicos,-> { select_basico.left_joins(:usuario, :especie => :adicional).join_usuarios2 }


  POR_PAGINA_PREDETERMINADO = 10
  RESUELTOS = [3,4] # Casos de comentarios marcados como resueltos
  RESPUESTA = 6 # Es una respuesta a un comentario
  OCULTAR = 5  # Nunca se borran comentarios, a lo mas los ocualtamos de la vista
  MODERADOR = 1  # Significa que esta pendiente de mostrarse en la ficha

  # REVISADO: Verifica no validar nombre si ya inicio sesion
  def inicio_sesion?
    usuario_id.blank?
  end

  # REVISADO: Opciones para los estatus
  def self.options_for_select
    [['No público y pendiente',1],['Público y pendiente',2],['Público y resuelto',3],['No público y resuelto',4],['Eliminar',5]]
  end

  # REVISADO: Conviete a base 32 los ids de los comentarios para evitar que el numero sea muy grande
  def idABase32
    Comentario.transaction do
      idBase32 = Comentario.where(:id => '', :created_at => self.created_at.to_time, :comentario => self.comentario)[0].idConsecutivo.to_s(32)
      update_column(:id, idBase32)
      ComentarioGeneral.new(comentario_id: idBase32, subject: '', commentArray: [].to_s).save if categorias_contenido_id == CategoriasContenido::COMENTARIO_ENCICLOVIDA
    end
  end

  # Completa el nombre, correo y de quien es el comentario (OP o respuesta)
  def completa_info(root_usuario_id=nil)
    if usuario_id.present?
      self.es_propietario = root_usuario_id == self.usuario_id ? true : false

      begin  # Por si viene del scope datos_basicos y encontro el usuario
        self.nombre = u_nombre
        self.correo = u_email
        self.institucion = u_institucion
      rescue
        u = usuario
        self.nombre = "#{u.nombre} #{u.apellido}".strip
        self.correo = u.email
        self.institucion = u.institucion
      end

    else  # Por si no esta el usuario_id
      begin  # Trato de ver si venia de un scope
        self.nombre = c_nombre
        self.institucion = c_institucion
        self.es_propietario = true
      rescue
        self.es_propietario = true
      end
    end
  end

end
