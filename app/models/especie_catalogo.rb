class EspecieCatalogo < ActiveRecord::Base

  self.table_name='especies_catalogos'
  belongs_to :especie
  belongs_to :catalogo

end
