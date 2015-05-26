class EnviaCorreo < Devise::Mailer
  default from: 'noreply@conabio.gob.mx'

  # Metodos adicionales
  def excel(usuario)
    mail(:to => 'calonsogeek@gmail.com', :subject => 'Taxonomia de: ' + usuario )
  end
end
