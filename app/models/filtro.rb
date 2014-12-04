class Filtro < ActiveRecord::Base

  def self.consulta(usuario, sesion)
    if usuario.instance_of?(Usuario)
      if usuario.filtro.present?
        usuario.filtro
      else
        return unless f = where(:sesion => sesion).first
        f.usuario_id = usuario.id
        f if f.save
      end
    else
      where(:sesion => sesion).first
    end
  end

  def self.guarda(sesion, usuario, html)    #guarda los filtros, o da lectura de ellos
    filtro = consulta(usuario, sesion)
    filtro = Filtro.new unless filtro.present?

    filtro.html = html
    filtro.usuario_id = usuario.id if usuario
    filtro.sesion = sesion

    if filtro.new_record?
      filtro.save
    else
      filtro.save if filtro.changed?
    end
  end

  def self.destruye(sesion, usuario)    # Destruye el filtro asociado
    if usuario.instance_of?(Usuario)
      usuario.filtro.destroy
    else
      filtro = where(:sesion => sesion).first
      return unless filtro
      filtro.destroy
    end
  end
end
