class TipoDistribucion < ActiveRecord::Base

  self.table_name='tipos_distribuciones'
  self.primary_key='id'

  has_many :especies_regiones

end
