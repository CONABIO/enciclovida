require 'digest/sha2'

class Usuario < ActiveRecord::Base

  self.table_name='usuarios'
  has_many :usuario_roles, :class_name=> 'UsuarioRol', :foreign_key => :usuario_id
  has_many :usuario_especies, :class_name=> 'UsuarioEspecie', :foreign_key => :usuario_id
  has_one :filtro, :class_name => 'Filtro', :foreign_key => :usuario_id
  attr_accessor :login
  validates :nombre, :apellido, presence: true

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :omniauthable, :lockable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable, :timeoutable,
         :authentication_keys => [:login]

  scope :usuarios_roles,-> { joins('LEFT JOIN usuarios_roles on usuarios.id = usuarios_roles.usuario_id') }
  scope :roles,-> { joins('LEFT JOIN roles on usuarios_roles.rol_id = roles.id') }
  scope :usuarios_especies,-> { joins('LEFT JOIN usuarios_especie on usuarios_especie.usuario_id = usuarios.id') }
  scope :especies,-> { joins('LEFT JOIN especies on especie_id = especies.id') }
  scope :categorias_contenidos_roles,-> { joins('LEFT JOIN categoria_contenidos_roles on roles.id = categoria_contenidos_roles.rol_id') }
  scope :categorias_contenidos,-> { joins('LEFT JOIN categorias_contenido on categoria_contenido_id = categorias_contenido.id') }
  scope :select_para_joins, -> { select("usuarios.id, usuarios.nombre, usuarios.apellido, usuarios.email, usuarios.institucion, usuarios.observaciones, roles.nombre_rol, especies.id as id_especie, especies.nombre_cientifico, categorias_contenido.nombre as nombre_cc")}
  scope :join_user_rol_categorias_contenido,-> { select_para_joins.usuarios_roles.roles.usuarios_especies.especies.categorias_contenidos_roles.categorias_contenidos }


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
