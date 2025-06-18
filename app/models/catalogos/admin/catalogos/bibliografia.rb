class Admin::Bibliografia < Bibliografia

  validates :autor, :anio, :titulo_publicacion, presence: true
  validates :autor, :titulo_publicacion, :titulo_publicacion, :titulo_sub_publicacion, :editorial_pais_pagina, :numero_volumen_anio, :editores_compiladores, :observaciones, length: { maximum: 255 }
  
  scope :autocompleta, ->(termino) { select(:id, :cita_completa).where("#{Bibliografia.attribute_alias(:cita_completa)} LIKE ? COLLATE utf8_general_ci", "%#{termino}%").limit(10) }

  before_save :asigna_cita_completa
  before_update :asigna_usuario
  
  def asigna_cita_completa
    orden_cita    = []
    orden_cita[0] = autor
    orden_cita[1] = anio
    orden_cita[2] = titulo_sub_publicacion
    orden_cita[3] = titulo_publicacion
    orden_cita[4] = editores_compiladores
    orden_cita[5] = numero_volumen_anio
    orden_cita[6] = editorial_pais_pagina

    self.cita_completa = orden_cita.join('. ').gsub('..','.').gsub('  ','').strip
  end

  def asigna_usuario
    cambios = changes.keys

    # Regresa el valor original del usuario si no se edito nada
    if cambios.length == 1 && cambios.include?('usuario')
      self.usuario = usuario_was
    end
  end

end
