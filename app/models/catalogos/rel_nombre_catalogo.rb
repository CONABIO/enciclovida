class RelNombreCatalogo < ActiveRecord::Base
  self.table_name = "#{CONFIG.bases.cat}.RelNombreCatalogo"
  self.primary_key = 'IdNombre'

  belongs_to :transforma_nombre, foreign_key: 'IdNombre', class_name: 'TransformaNombre'
  belongs_to :catalogo, foreign_key: 'IdCatNombre', class_name: 'Catalogo'

end




