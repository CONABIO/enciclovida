require 'digest/sha2'

class Usuario < ActiveRecord::Base

  self.table_name='usuarios'
  belongs_to :rol
  has_one :filtro, :class_name => 'Filtro', :foreign_key => :usuario_id
  attr_accessor :login

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :omniauthable, :lockable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable, :timeoutable,
         :authentication_keys => [:login]

  def self.autentica(login, contrasenia)
    usuario = where("usuario='#{login}' OR correo='#{login}'")
    if usuario.count == 1
      if usuario.first.contrasenia == self.contraseniaEncryptada(contrasenia, usuario.first.salt)
        usuario.first
      else
        nil
      end
    else
      nil
    end
  end

  def self.contraseniaEncryptada(contrasenia, salt)
    Digest::SHA2.hexdigest(contrasenia + salt)
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["LOWER(usuario) = :value OR LOWER(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def es_admin?
    rol.prioridad >= 100
  end

  private
  def generaContrasenia
    self.salt = self.nombre.to_s + rand.to_s
    self.contrasenia=Digest::SHA2.hexdigest(self.confirma_contrasenia+self.salt)
  end

  def comparaContrasenia
    errors.add(:confirma_contrasenia, 'debe ser la misma que la confrimación') if self.contrasenia != self.confirma_contrasenia
  end
end
