class EspecieBibliografia < ActiveRecord::Base
  self.table_name='especies_bibliografias'
  self.primary_keys= :especie_id, :bibliografia_id

  belongs_to :especie
  belongs_to :bibliografia
end
