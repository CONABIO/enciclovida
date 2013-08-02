class EspecieRegion < ActiveRecord::Base

  self.table_name='especies_regiones'
  belongs_to :region
  belongs_to :especie
  belongs_to :tipo_distribucion
  has_many :nombres_regiones_especie, :class_name => 'NombreRegion', :foreign_key => 'especie_id'

end
