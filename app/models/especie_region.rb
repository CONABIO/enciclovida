class EspecieRegion < ActiveRecord::Base

  self.table_name='especies_regiones'
  self.primary_keys= :especie_id, :region_id
  attr_accessor :region_id_falso
  validates_presence_of :especie_id, :region_id
  belongs_to :region
  belongs_to :especie
  belongs_to :tipo_distribucion
  has_many :nombres_regiones, :class_name => 'NombreRegion', :foreign_key => 'especie_id', :dependent => :destroy

end
