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
    @comentario.completa_nombre_correo_especie


  end
end
