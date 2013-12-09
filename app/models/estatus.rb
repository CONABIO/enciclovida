class Estatus < ActiveRecord::Base
  self.table_name='estatuses'
  has_many :especie_estatuses
end
