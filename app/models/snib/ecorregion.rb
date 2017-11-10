class Ecorregion < ActiveRecord::Base
  establish_connection(:snib)
  self.table_name = 'ecorregiones1'
  self.primary_key = 'ecorid'

  scope :campos_min, -> { select('ecorid AS region_id, desecon1 AS nombre_region').order(desecon1: :asc) }
  scope :campos_geom, -> { select('ST_AsGeoJSON(the_geom) AS geojson, st_x(st_centroid(the_geom)) AS long, st_y(st_centroid(the_geom)) AS lat') }
  scope :geojson, ->(region_id) { select('ST_AsGeoJSON(the_geom) AS geojson').where(ecorid: region_id) }
end