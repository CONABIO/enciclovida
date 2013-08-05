class Catalogo < ActiveRecord::Base

  self.table_name='catalogos'
  has_many :especies_catalogos

end
