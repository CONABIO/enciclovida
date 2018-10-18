class ComentarioGeneral < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.ev}.comentarios_generales"
  self.primary_key = 'id'

  belongs_to :comentario

end
