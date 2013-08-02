class TipoRegion < ActiveRecord::Base

  self.table_name='tipos_regiones'
  has_many :regiones

end
