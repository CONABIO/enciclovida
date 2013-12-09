class NombreRegionBibliografia < ActiveRecord::Base

  self.table_name='nombres_regiones_bibliografias'
  self.primary_keys= :especie_id, :region_id, :nombre_comun_id, :bibliografia_id
  attr_accessor :bibliografia_id_falsa
  belongs_to :especie
  belongs_to :region
  belongs_to :bibliografia
  belongs_to :nombre_comun

end
