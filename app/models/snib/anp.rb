class Anp < ActiveRecord::Base
  establish_connection(:snib)
  self.table_name = 'anpestat'
  self.primary_key = 'anpestid'

  scope :campos_min, -> { select('anpestid AS region_id, CONCAT(nombre, \', \', entidad) AS nombre_region').order(nombre: :asc) }
  scope :campos_geom, -> { select('ST_AsGeoJSON(the_geom) AS geojson, st_x(st_centroid(the_geom)) AS long, st_y(st_centroid(the_geom)) AS lat') }
  scope :geojson, ->(region_id) { select('ST_AsGeoJSON(the_geom) AS geojson').where(anpestid: region_id) }
end