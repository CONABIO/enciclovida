require 'digest/sha2'

class Usuario < ActiveRecord::Base

  self.table_name='usuarios'
  belongs_to :rol
  has_one :filtro, :class_name => 'Filtro', :foreign_key => :usuario_id
  attr_accessor :login
  validates :nombre, :apellido, presence: true

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :omniauthable, :lockable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable, :timeoutable,
         :authentication_keys => [:login]

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where('LOWER(email) = ?', login.downcase).first
    else
      where(conditions).first
    end
  end

  def es_admin?
    rol.prioridad >= 100
  end
end
