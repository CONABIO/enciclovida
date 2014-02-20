module ApplicationHelper
  def bitacora
    if Rol::CON_BITACORA.include?(Usuario.find(session[:usuario]).rol_id.to_s)
      addon='<ul>'
      Bitacora.all.order('id DESC').limit(10).each do |bitacora|
        addon+="<li>#{link_to(bitacora.usuario.usuario, bitacora.usuario)} #{bitacora.descripcion}</li>"
      end
      addon
    else
      ''
    end
  end
end
