class ComentarioGeneral < ActiveRecord::Base

  establish_connection(Rails.env.to_sym)
  self.table_name = :comentarios_generales
  self.primary_key = 'id'

  belongs_to :comentario

end
