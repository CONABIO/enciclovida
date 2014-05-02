class EspecieBibliografia < ActiveRecord::Base
  self.table_name='especies_bibliografias'
  belongs_to :especie
  belongs_to :bibliografia
end
