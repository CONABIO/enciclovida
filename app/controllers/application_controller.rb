class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :enlacesDelArbol

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

  def cierraSesion
    session[:usuario]=nil
    cookies.delete :SpryMedia_DataTables_especies_especies
    cookies.delete :SpryMedia_DataTables_especies_
  end

  def to_boolean(str)
    str == 'true'
  end
end
