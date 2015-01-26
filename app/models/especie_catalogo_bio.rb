class EspecieCatalogoBio < ActiveRecord::Base

  self.table_name='RelNombreCatalogo'
  self.primary_keys= :IdNombre, :IdCatNombre

  attr_accessor :catalogo_id_falso
  belongs_to :especie
  belongs_to :catalogo

  #validates_uniqueness_of :especie_id, :scope => :catalogo_id
end
