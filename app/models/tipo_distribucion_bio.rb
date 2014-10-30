class TipoDistribucionBio < ActiveRecord::Base

  self.table_name='TipoDistribucion'
  self.primary_key='IdTipoDistribucion'

  has_many :especies_regiones
end
