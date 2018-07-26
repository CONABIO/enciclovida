class Municipio < ActiveRecord::Base

  establish_connection(:snib)
  self.primary_key = 'munid'

  scope :campos_min, -> { select('cve_mun AS region_id, cve_ent AS parent_id, municipio AS nombre_region, munid AS region_id_se').order(municipio: :asc) }
  scope :centroide, -> { select('st_x(st_centroid(the_geom)) AS long, st_y(st_centroid(the_geom)) AS lat') }
  scope :geojson_select, -> { select('ST_AsGeoJSON(the_geom) AS geojson') }
  scope :campos_geom, -> { centroide.geojson_select }
  scope :geojson, ->(region_id, parent_id) { geojson_select.where(cve_mun: region_id, cve_ent: parent_id) }
  
end