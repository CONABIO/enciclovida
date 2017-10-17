class Municipio < ActiveRecord::Base
  self.primary_key = 'munid'
  establish_connection(:snib)

  scope :campos_min, -> { select('cve_ent AS region_id, cve_mun AS parent_id, CONCAT(municipio, \', \', estado) AS nombre_region').order(municipio: :asc) }
end