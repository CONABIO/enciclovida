class Criterio < ActiveRecord::Base

  establish_connection(:peces)
  self.table_name='criterios'

  belongs_to :propiedad

end