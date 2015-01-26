class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :set_locale#, :authenticate  ##Autentica por credenciales generales
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
    I18n.locale = params[:locale] || usuario_signed_in? ? current_usuario.locale : nil || dameLocaleFiltro || I18n.default_locale
  end


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

  def paginacion(totales, pag = 1, p_pag = Especie::POR_PAGINA_PREDETERMINADO)
    pagina = pag.to_i
    por_pagina = p_pag.to_i
    paginas = totales/por_pagina + 1    # + 1 porque puede que totales%por_pagina no sea cero
    rangos = []

    if paginas <= 12
      rangos << (1..paginas).to_a
    elsif paginas > 12
      if pagina.between?(1,8)
        rangos << (1..10).to_a
        rangos << '...'
        rangos << (paginas-1..paginas).to_a
      elsif pagina.between?(9,paginas-10)
        rangos << (1..2).to_a
        rangos << '...'
        rangos << (pagina-4..pagina+4).to_a
        rangos << '...'
        rangos << (paginas-1..paginas).to_a
      elsif pagina.between?(paginas-9, paginas)
        rangos << (1..2).to_a
        rangos << '...'
        rangos << (paginas-10..paginas).to_a
      end
    end

    { :rangos => rangos, :pagina => pagina, :rango_resultados => "Mostrando #{(pagina-1)*por_pagina+1} - #{pagina*por_pagina <= totales ? pagina*por_pagina : (pagina-1)*por_pagina + totales%por_pagina} de #{totales}",
      :request => request.fullpath, :por_pagina => por_pagina, :totales => totales }
  end
end
