class TipoRegion < ActiveRecord::Base

  self.table_name='tipos_regiones'
  self.primary_key='id'
  has_many :regiones

end
