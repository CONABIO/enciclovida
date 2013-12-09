class NombreRegion < ActiveRecord::Base

  self.table_name='nombres_regiones'
  self.primary_keys= :especie_id, :region_id, :nombre_comun_id
  attr_accessor :nombre_comun_id_falso
  belongs_to :region
  belongs_to :especie
  belongs_to :nombre_comun
  has_many :nombres_regiones_bibliografias, :class_name => 'NombreRegionBibliografia', :foreign_key => 'especie_id'

end
