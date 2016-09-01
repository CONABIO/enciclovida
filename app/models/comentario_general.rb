class ComentarioGeneral < ActiveRecord::Base
  self.table_name = :comentarios_generales
  self.primary_key = 'id'

  belongs_to :comentario
end
