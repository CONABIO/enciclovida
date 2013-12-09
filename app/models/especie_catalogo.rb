class EspecieCatalogo < ActiveRecord::Base

  self.table_name='especies_catalogos'
  self.primary_keys= :especie_id, :catalogo_id
  attr_accessor :catalogo_id_falso
  belongs_to :especie
  belongs_to :catalogo

  #validates_uniqueness_of :especie_id, :scope => :catalogo_id
end
