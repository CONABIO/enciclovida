class EspecieEstatus < ActiveRecord::Base
  self.table_name='especies_estatuses'
  self.primary_keys= :especie_id1, :especie_id2, :estatus_id
  belongs_to :especie, :foreign_key => :especie_id1
  belongs_to :especie, :foreign_key => :especie_id2
  belongs_to :estatus
end
