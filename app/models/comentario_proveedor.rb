class ComentarioProveedor < ActiveRecord::Base

  establish_connection(Rails.env.to_sym)
  self.table_name = 'comentarios_proveedores'

  # Tipos de comentarios que se asociaran con su respectivo ID
  TIPO_COMENTARIO = %w(SNIB NaturaLista Fotos Geoserver Fichas)

end
