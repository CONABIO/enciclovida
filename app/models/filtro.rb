class Filtro < ActiveRecord::Base

  def self.sesion_o_usuario(sesion, usuario, html, lectura)    #guarda los filtros, o da lectura de ellos
    filtro=usuario.present? ? where(:usuario_id => usuario) : where(:sesion => sesion)
    if filtro.present?
      f=filtro.first
      f.html=html if !lectura
      f.usuario_id=usuario if usuario.present?
      f.sesion=sesion

      if f.changed?
        {:existia => true, :html => lectura ? f.html: nil} if f.save
      else
        {:existia => true, :html => lectura ? f.html: nil}
      end
    else
      nuevo = new(:html => html, :sesion => sesion, :usuario_id => usuario.present? ? usuario : nil)
      {:existia => false} if nuevo.save
    end
  end

  def self.consulta(sesion, usuario)    #consulta para ver si existe registro
    filtro=usuario.present? ? where(:usuario_id => usuario) : where(:sesion => sesion)
    if filtro.present?
      filtro.first.destroy
      filtro.first.destroyed?
    else
      true
    end
  end
end
