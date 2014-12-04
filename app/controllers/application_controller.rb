class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :set_locale
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

  def set_locale
    I18n.locale = params[:locale]
    I18n.locale = usuario_signed_in? ? current_usuario.locale : nil unless I18n.locale
    I18n.locale = dameLocaleFiltro unless I18n.locale
    I18n.locale = I18n.default_locale unless I18n.locale
  end


  private

  def dameLocaleFiltro
    return unless filtro = Filtro.where(:sesion => request.session_options[:id]).first
    filtro.locale
  end

  protected

  def configure_permitted_parameters
    #Atributos adicionales al modelo
    devise_parameter_sanitizer.for(:sign_up) << :usuario
    devise_parameter_sanitizer.for(:sign_up) << :nombre
    devise_parameter_sanitizer.for(:sign_up) << :apellido
    devise_parameter_sanitizer.for(:sign_up) << :institucion
    devise_parameter_sanitizer.for(:sign_up) << :grado_academico
    #devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:usuario, :email ) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :usuario, :email, :password, :remember_me) }
  end
end
