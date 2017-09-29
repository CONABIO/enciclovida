class EnviaCorreo < Devise::Mailer
  default from: 'noreply@conabio.gob.mx'

  # Metodos adicionales
  def excel(validacion)
    @ruta_excel = validacion.excel_url
    mail(:to => validacion.correo, :subject => "EncicloVida: validacion/descarga de #{validacion.nombre_archivo}")
  end

  def respuesta_comentario(comentario)
    completa_datos_comentario(comentario)
    mail(:to => @comentario_root.correo, :subject => 'EncicloVida: Respuesta a comentario') if (Rails.env.production? || @comentario_root.correo.include?("ggonzalez") || @comentario_root.correo.include?("calonso") || @comentario_root.correo.include?("albertoglezba") || @comentario_root.correo.include?("mailinator"))
  end

  def comentario_resuelto(comentario)
    completa_datos_comentario(comentario)
    mail(:to => @comentario_root.correo, :subject => 'EncicloVida: Comentario resuelto') if (Rails.env.production? || @comentario_root.correo.include?("ggonzalez") || @comentario_root.correo.include?("calonso") || @comentario_root.correo.include?("albertoglezba") || @comentario_root.correo.include?("mailinator"))
  end

  def confirmacion_comentario(comentario)
    completa_datos_comentario(comentario)
    mail(:to => @comentario_root.correo, :subject => 'EncicloVida: Comentario recibido') if (Rails.env.production? || @comentario_root.correo.include?("ggonzalez") || @comentario_root.correo.include?("calonso") || @comentario_root.correo.include?("albertoglezba") || @comentario_root.correo.include?("mailinator"))
  end

  def confirmacion_comentario_general(comentario)
    completa_datos_comentario(comentario)
    mail(:to => @comentario_root.correo, :subject => 'EncicloVida: Comentario recibido') if (Rails.env.production? || @comentario_root.correo.include?("ggonzalez") || @comentario_root.correo.include?("calonso") || @comentario_root.correo.include?("albertoglezba") || @comentario_root.correo.include?("mailinator"))
  end

  def descargar_taxa(ruta, correo)
    @ruta = ruta
    mail(:to => correo, :subject => 'EncicloVida: Descargar taxa')# if Rails.env.production?
  end

  def avisar_responsable_contenido(comentario,correos)
    completa_datos_comentario(comentario)
    mail(:to => correos.join(','), :subject => 'EncicloVida: Te ha sido asignado un comentario para solucionar') if (Rails.env.production? || correos.join(',').include?("ggonzalez") || correos.join(',').include?("calonso") || correos.join(',').include?("albertoglezba") || correos.join(',').include?("mailinator"))
  end

  private

  def completa_datos_comentario(comentario)
    @comentario = comentario
    @comentario_root = @comentario.root
    @comentario.completa_info(@comentario_root.usuario_id)

    if t = @comentario.especie
      @nombre_cientifico = t.nombre_cientifico

      if a = t.adicional
        @nombre_comun = a.nombre_comun_principal
      end
    end

    @comentario_root.completa_info(@comentario_root.usuario_id)
    @created_at = @comentario_root.created_at.strftime('%d-%m-%y_%H-%M-%S')
  end
end
