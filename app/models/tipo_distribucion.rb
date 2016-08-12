class TipoDistribucion < ActiveRecord::Base

  self.table_name='tipos_distribuciones'
  self.primary_key='id'

  has_many :especies_regiones

  # De esta forma las acomodo a como me convenga
  #IDEM as below, se sustituye introducida por exotica y exotica-invasora
  DISTRIBUCIONES = %w(nativa endemica no-endemica cuasiendemica semiendemica exotica exotica-invasora actual original)

  # Quita algunos tipos de distribucion que no son validos
  QUITAR_DIST = %w(actual original invasora)

  # Quita algunos tipos de distribucion que quiere Carlos G.
  QUITAR_DIST_SOLO_BASICA = %w(no-endemica cuasiendemica semiendemica)

  # Ponerlos en un orden muy específico unicamente para la vista general tal cual como lo pide Carlos G.
  #Se agrego exótica y exótica-invasora en lugar de introducida
  DISTRIBUCIONES_SOLO_BASICA = %w(endemica nativa exotica exotica-invasora)
end
