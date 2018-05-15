class Propiedad < ActiveRecord::Base

  establish_connection(:peces)
  self.table_name='propiedades'

  has_ancestry

end