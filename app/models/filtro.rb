class Filtro < ActiveRecord::Base

  def self.sesion_o_usuario(sesion, usuario, html, carga)    #guarda los filtros, o da lectura de ellos
    filtro = usuario.instance_of?(Usuario) ? usuario.filtro : where(:sesion => sesion).first

    if filtro
      html_cambio = filtro.html != html            # Para saber si reemplazar o no el html
      filtro.html = html if html_cambio && !carga  # Si es carga de pagina, no escribe los filtros
      filtro.usuario_id = usuario.id if usuario
      filtro.sesion = sesion
      filtro.save if filtro.changed?
      # Si el html cambio nos lo enviamos
      { :existia => true, :html => html_cambio && carga ? filtro.html : nil }
    else
      nuevo = new(:html => html, :sesion => sesion, :usuario_id => usuario ? usuario.id : usuario)
      { :existia => false } if nuevo.save
    end
  end

  def self.destruye(sesion, usuario)    #consulta para ver si existe registro
    if usuario.instance_of?(Usuario)
      usuario.filtro.destroy
    else
      filtro = where(:sesion => sesion).first
      return unless filtro
      filtro.destroy
    end
  end
end
