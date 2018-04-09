class EnviaCorreo < Devise::Mailer
  default from: 'noreply@conabio.gob.mx'

  # Metodos adicionales
  def excel(validacion)
    @ruta_excel = validacion.excel_url
    mail(:to => "ggonzalez@conabio.gob.mx", :subject => "EncicloVida: validacion/descarga de #{validacion.nombre_archivo}--[#{validacion.correo}")
    #mail(:to => validacion.correo, :subject => "EncicloVida: validacion/descarga de #{validacion.nombre_archivo}")
  end

  def respuesta_comentario(comentario)
    completa_datos_comentario(comentario)
    mail(:to => "ggonzalez@conabio.gob.mx", :subject => "EncicloVida: Respuesta a comentario--[#{@comentario_root.correo}")
    #mail(:to => @comentario_root.correo, :subject => 'EncicloVida: Respuesta a comentario') if debo_enviar_correos?(@comentario_root.correo)
  end

  def comentario_resuelto(comentario)
    completa_datos_comentario(comentario)
    mail(:to => "ggonzalez@conabio.gob.mx", :subject => "EncicloVida: Comentario resuelto--[#{@comentario_root.correo}")
    #mail(:to => @comentario_root.correo, :subject => 'EncicloVida: Comentario resuelto') if debo_enviar_correos?(@comentario_root.correo)
  end

  def confirmacion_comentario(comentario)
    completa_datos_comentario(comentario)
    mail(:to => "ggonzalez@conabio.gob.mx", :subject => "EncicloVida: Comentario recibido--[#{@comentario_root.correo}")
    #mail(:to => @comentario_root.correo, :subject => 'EncicloVida: Comentario recibido') if debo_enviar_correos?(@comentario_root.correo)
  end

  def confirmacion_comentario_general(comentario)
    completa_datos_comentario(comentario)
    mail(:to => "ggonzalez@conabio.gob.mx", :subject => "EncicloVida: Comentario recibido--[#{@comentario_root.correo}")
    #mail(:to => @comentario_root.correo, :subject => 'EncicloVida: Comentario recibido') if debo_enviar_correos?(@comentario_root.correo)
  end

  def descargar_taxa(ruta, correo)
    @ruta = ruta
    mail(:to => "ggonzalez@conabio.gob.mx", :subject => "EncicloVida: Descargar taxa--[#{@comentario_root.correo}") #Linea para debuggear los envios personalizados
    #mail(:to => correo, :subject => 'EncicloVida: Descargar taxa')
  end

  def avisar_responsable_contenido(comentario,correos)
    completa_datos_comentario(comentario)
    @correos = correos
    mail(:to => "ggonzalez@conabio.gob.mx", :subject => 'EncicloVida: Te ha sido asignado un comentario para solucionar') #Linea para debuggear los envios personalizados
    #mail(:to => correos.join(','), :subject => 'EncicloVida: Te ha sido asignado un comentario para solucionar') if debo_enviar_correos?(correos)
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

  def debo_enviar_correos?(correos)
    correos = [correos] ##Por si recibo un string solamente
    Rails.env.production? || correos.join.include?("ggonzalez") || correos.join.include?("calonso") || correos.join.include?("albertoglezba") || correos.join.include?("mailinator")
  end
end
