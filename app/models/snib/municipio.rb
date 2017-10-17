class Municipio < ActiveRecord::Base
  establish_connection(:snib)
  self.primary_key = 'munid'

  scope :campos_min, -> { select('cve_mun AS region_id, cve_ent AS parent_id, CONCAT(municipio, \', \', estado) AS nombre_region').order(municipio: :asc) }
end