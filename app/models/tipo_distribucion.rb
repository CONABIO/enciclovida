class TipoDistribucion < ActiveRecord::Base

  self.table_name='tipos_distribuciones'
  self.primary_key='id'

  has_many :especies_regiones

  # De esta forma las acomodo a como me convenga
  DISTRIBUCIONES = %w(nativa endemica no_endemica cuasiendemica semiendemica introducida invasora actual original)

  # Quita algunos tipos de distribucion que no son validos
  QUITAR_DIST = %w(actual original)

  # Quita algunos tipos de distribucion que quiere Carlos G.
  QUITAR_DIST_SOLO_BASICA = %w(no_endemica cuasiendemica semiendemica)

  # Ponerlos en un orden muy específico unicamente para la vista general tal cual como lo pide Carlos G.
  DISTRIBUCIONES_SOLO_BASICA = %w(introducida invasora endemica nativa)
end
