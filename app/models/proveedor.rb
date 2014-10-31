class Proveedor < ActiveRecord::Base
  self.primary_key = :especie_id
  belongs_to :especie
end
