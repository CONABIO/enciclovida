class EnviaCorreo < Devise::Mailer
  default from: 'noreply@conabio.gob.mx'

  # Metodos adicionales
  def excel(validacion)
    usuario = validacion.usuario
    @ruta_excel = "#{CONFIG.servidor_bios}/assets/validaciones_excel/#{usuario.id}/#{validacion.nombre_archivo}.xlsx"
    mail(:to => usuario.email, :subject => "Validacion de #{validacion.nombre_archivo}")

    validacion.enviado = 1
    validacion.fecha_envio = Time.now
    validacion.save
  end
end
