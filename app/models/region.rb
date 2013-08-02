class Region < ActiveRecord::Base

  self.table_name='regiones'
  belongs_to :tipo_region
  has_many :especies_regiones, :class_name => 'EspecieRegion', :foreign_key => 'region_id'
  has_ancestry

end
