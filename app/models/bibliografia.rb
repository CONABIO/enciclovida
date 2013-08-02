class Bibliografia < ActiveRecord::Base

  self.table_name='bibliografias'
  has_many :nombres_regiones_bibligrafias

end
