class Municipio < ActiveRecord::Base
  establish_connection(:snib)
  self.primary_key = 'munid'

  scope :campos_min, -> { select('cve_mun AS region_id, cve_ent AS parent_id, municipio AS nombre_region').order(municipio: :asc) }
  scope :geojson, ->(region_id, parent_id) { select('ST_AsGeoJSON(the_geom) AS geojson').where(cve_mun: region_id, cve_ent: parent_id) }
end