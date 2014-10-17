class Estatus < ActiveRecord::Base
  self.table_name='estatuses'
  self.primary_key='id'

  has_many :especie_estatuses
end
