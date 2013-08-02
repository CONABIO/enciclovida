class NombreRegionBibliografia < ActiveRecord::Base

  self.table_name='nombres_regiones_bibliografias'
  belongs_to :especie
  belongs_to :region
  belongs_to :bibliografia
  belongs_to :nombre_comun

end
