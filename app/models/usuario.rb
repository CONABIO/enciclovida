require 'digest/sha2'

class Usuario < ActiveRecord::Base

  self.table_name='usuarios'

  # Para validar un correo y otros modelos lo puedan utilizar
  nombre_correo_regex  = '[\w\.%\+\-]+'.freeze
  dominio_regex = '(?:[A-Z0-9\-]+\.)+'.freeze
  dominio_tld_regex  = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)'.freeze
  CORREO_REGEX       = /\A#{nombre_correo_regex}@#{dominio_regex}#{dominio_tld_regex}\z/i
  CORREO_INVALIDO_MSG = 'El correo no tiene la estructura apropiada.'.freeze

  has_many :usuario_roles, :class_name=> 'UsuarioRol', :foreign_key => :usuario_id
  has_many :roles, :through => :usuario_roles, :source => :rol
  has_many :categorias_contenidos, :through => :roles, :source => :categorias_contenidos

  has_many :usuario_especies, :class_name=> 'UsuarioEspecie', :foreign_key => :usuario_id
  has_many :especies, :through => :usuario_especies, :source => :especie

  has_one :filtro, :class_name => 'Filtro', :foreign_key => :usuario_id
  attr_accessor :login
  validates :nombre, :apellido, presence: true

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :omniauthable, :lockable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable, :timeoutable,
         :authentication_keys => [:login]

  scope :usuariosRoles,-> { joins('LEFT JOIN usuarios_roles on usuarios.id = usuarios_roles.usuario_id LEFT JOIN roles on usuarios_roles.rol_id = roles.id') }
  scope :usuariosEspecies,-> { joins('LEFT JOIN usuarios_especie on usuarios_especie.usuario_id = usuarios.id LEFT JOIN especies on especie_id = especies.id') }
  scope :rolesCategoriasContenido,-> { joins('LEFT JOIN roles_categorias_contenido on roles.id = roles_categorias_contenido.rol_id LEFT JOIN categorias_contenido on categorias_contenido_id = categorias_contenido.id') }
  scope :select_para_joins, -> { select("usuarios.id, usuarios.nombre, usuarios.apellido, usuarios.email, usuarios.institucion, usuarios.observaciones, roles.nombre_rol, especies.id as id_especie, especies.nombre_cientifico, categorias_contenido.nombre as nombre_cc")}
  scope :join_userRolEspeciesCategoriasContenido,-> { select_para_joins.usuariosRoles.usuariosEspecies.rolesCategoriasContenido }


  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where('LOWER(email) = ?', login.downcase).first
    else
      where(conditions).first
    end
  end

  def nombre_completo
    "#{id}. #{nombre} #{apellido}"
  end
end
