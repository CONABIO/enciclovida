class EnviaCorreo < Devise::Mailer
  default from: 'noreply@conabio.gob.mx'

  # Metodos adicionales
  def excel(validacion)
    usuario = validacion.usuario
    @ruta_excel = "#{CONFIG.servidor_bios}/validaciones_excel/#{usuario.id}/#{validacion.nombre_archivo}.xlsx"
    mail(:to => usuario.email, :subject => "EncicloVida: validacion de #{validacion.nombre_archivo}")

    validacion.enviado = 1
    validacion.fecha_envio = Time.now
    validacion.save
  end

  def respuesta_comentario(comentario)
    completa_datos_comentario(comentario)
    mail(:to => @comentario_root.correo, :subject => 'EncicloVida: Respuesta a comentario') if (Rails.env.production? || @comentario_root.correo.include?("ggonzalez") || @comentario_root.correo.include?("calonso") || @comentario_root.correo.include?("albertoglezba"))
  end

  def comentario_resuelto(comentario)
    completa_datos_comentario(comentario)
    mail(:to => @comentario_root.correo, :subject => 'EncicloVida: Comentario resuelto') if (Rails.env.production? || @comentario_root.correo.include?("ggonzalez") || @comentario_root.correo.include?("calonso") || @comentario_root.correo.include?("albertoglezba"))
  end

  def confirmacion_comentario(comentario)
    completa_datos_comentario(comentario)
    mail(:to => @comentario_root.correo, :subject => 'EncicloVida: Comentario recibido') if (Rails.env.production? || @comentario_root.correo.include?("ggonzalez") || @comentario_root.correo.include?("calonso") || @comentario_root.correo.include?("albertoglezba"))
  end

  def descargar_taxa(ruta, correo)
    @ruta = ruta
    mail(:to => correo, :subject => 'EncicloVida: Descargar taxa')# if Rails.env.production?
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
