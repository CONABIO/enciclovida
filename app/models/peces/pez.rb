class Pez < ActiveRecord::Base

  establish_connection(:peces)
  self.table_name='peces'
  self.primary_key='especie_id'

  belongs_to :especie

end