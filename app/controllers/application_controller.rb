class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?

  def ponSesion(usuario)
    session[:usuario] = usuario.id
  end

  def dameUsuario
    if verificaSesion
      session[:usuario]
    else
      nil
    end
  end

  def dameObjUsuario
    if verificaSesion
      Usuario.find(session[:usuario])
    else
      nil
    end
  end

  def inicioSesion?
    session[:usuario].present? ? session[:usuario] : nil
  end

  def verificaSesion
    session[:usuario].present? ? true : false
  end

  def entroAlSistema?
    if verificaSesion
      true
    else
      respond_to do |format|
        format.html { redirect_to inicia_sesion_usuarios_url, notice: 'Tienes que iniciar sesión primero.' }
      end
    end
  end

  def tienePermiso?(objeto=nil)
    if verificaSesion
      usuario=Usuario.find(session[:usuario]).rol
      if usuario.es_admin == 1 || usuario.es_super_usuario == 1
        true
      elsif objeto.present?
        if objeto == session[:usuario]
          true
        else
          respond_to do |format|
            format.html { redirect_to :root, notice: 'Lo sentimos no estás autorizado para realizar esta operación. Si tienes alguna sugerencia contactanos' }
          end
        end
      else
        respond_to do |format|
          format.html { redirect_to :root, notice: 'Lo sentimos no estás autorizado para realizar esta operación. Si tienes alguna sugerencia contactanos' }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to inicia_sesion_usuarios_url, notice: 'Tienes que iniciar sesión primero.' }
      end
    end
  end

  def get_flickraw
    #current_user ? FlickrPhoto.flickraw_for_user(current_user) : flickr
    FlickRaw.api_key = FLICKR_API_KEY
    FlickRaw.shared_secret = FLICKR_SHARED_SECRET
    flickr
  end

  def cierraSesion
    session[:usuario]=nil
    cookies.delete :SpryMedia_DataTables_especies_especies
    cookies.delete :SpryMedia_DataTables_especies_
  end

  def to_boolean(str)
    str.downcase == 'true' ? true : false
  end

  def dameLocaleFiltro
    filtro = Filtro.where(:sesion => request.session_options[:id])
    filtro.first ? filtro.first.locale : nil
  end

  def set_locale
    I18n.locale = params[:locale] || dameObjUsuario.try(:locale) || dameLocaleFiltro || I18n.default_locale
    I18n.locale = dameObjUsuario.try(:locale) if I18n.locale.blank?
    I18n.locale = I18n.default_locale if I18n.locale.blank?
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
