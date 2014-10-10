require 'digest/sha2'

class Usuario < ActiveRecord::Base
  self.table_name='usuarios'
  belongs_to :rol
  attr_accessor :confirma_contrasenia
  validates :usuario, :presence => true, :uniqueness=>true
  validates :correo, :presence => true, :uniqueness=>true
  validates :nombre, :presence => true
  validates :apellido, :presence => true
  #validates :institucion, :presence => true
  #validates :grado_academico, :presence => true
  validates :contrasenia, :presence => true, :on => :create
  validates :confirma_contrasenia, :presence => true, :on => :create
  validate :comparaContrasenia, :on => :create

  before_create :generaContrasenia

  login_regex       = /\A[A-z][\w\-_]+\z/
  bad_login_message = "use only letters, numbers, and -_ please.".freeze
  email_name_regex  = '[\w\.%\+\-]+'.freeze
  domain_head_regex = '(?:[A-Z0-9\-]+\.)+'.freeze
  domain_tld_regex  = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)'.freeze
  email_regex       = /\A#{email_name_regex}@#{domain_head_regex}#{domain_tld_regex}\z/i
  bad_email_message = "no tiene la estructura apropiada.".freeze

  validates_format_of :correo, :with => email_regex, :message => bad_email_message
  validates_length_of :correo, :within => 6..100

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

  private
  def generaContrasenia
    self.salt = self.nombre.to_s + rand.to_s
    self.contrasenia=Digest::SHA2.hexdigest(self.confirma_contrasenia+self.salt)
  end

  def comparaContrasenia
    errors.add(:confirma_contrasenia, "debe ser la misma que la confrimación") if self.contrasenia != self.confirma_contrasenia
  end

  def guarda_locale
    self.
  end

end
