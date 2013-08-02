class TipoDistribucion < ActiveRecord::Base

  self.table_name='tipos_distribuciones'
  has_many :especies_regiones

end
