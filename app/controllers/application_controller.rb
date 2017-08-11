class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  #before_filter :set_locale#, :authenticate  ##Autentica por credenciales generales
  before_action :configure_permitted_parameters, if: :devise_controller?

  def get_flickraw
    #current_user ? FlickrPhoto.flickraw_for_user(current_user) : flickr
    FlickRaw.api_key = FLICKR_API_KEY
    FlickRaw.shared_secret = FLICKR_SHARED_SECRET
    flickr
  end

  def to_boolean(str)
    str.downcase == 'true' ? true : false
  end

  #def set_locale
  #  I18n.locale = params[:locale] || (usuario_signed_in? ? current_usuario.locale : nil) || dameLocaleFiltro || I18n.default_locale
  #end


  private

  def dameLocaleFiltro
    return unless filtro = Filtro.where(:sesion => request.session_options[:id]).first
    filtro.locale
  end

  protected

  # Limita la aplicacion a un usuario y contrasenia general
  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == CONFIG.username.to_s && password == CONFIG.password.to_s
    end
  end

  # Atributos adicionales para el registro y autenticacion
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :email
    devise_parameter_sanitizer.for(:sign_up) << :nombre
    devise_parameter_sanitizer.for(:sign_up) << :apellido
    devise_parameter_sanitizer.for(:sign_up) << :institucion
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :email, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) << :email
    devise_parameter_sanitizer.for(:account_update) << :nombre
    devise_parameter_sanitizer.for(:account_update) << :apellido
    devise_parameter_sanitizer.for(:account_update) << :institucion
  end

  def tiene_permiso?(nombre_rol)
    render 'shared/sin_permiso' and return unless usuario_signed_in? #con esto aseguramos que el usuario ya inicio sesión
    roles_usuario = current_usuario.usuario_roles.map(&:rol)
    return if roles_usuario.map(&:depth).any?{|d| d < 1}
    rol = Rol.find_by_nombre_rol(nombre_rol)
    #Revisa si el nombre_rol pertenece al linaje (intersección del subtree_ids del usuario y del rol)
    render 'shared/sin_permiso' unless rol.present? && (roles_usuario.map(&:subtree_ids).flatten & rol.subtree_ids.flatten).any?
  end

  def es_propietario?(obj)
    if usuario_signed_in?
      usuario_id = obj.usuario_id

      if current_usuario.id == usuario_id
        true
      else
        false
      end
    else
      false
    end
  end

end
