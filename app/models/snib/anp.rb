class Anp < ActiveRecord::Base
  establish_connection(:snib)
  self.table_name = 'anpestat'
  self.primary_key = 'anpestid'

  scope :campos_min, -> { select('anpestid AS region_id, CONCAT(nombre, \', \', entidad) AS nombre_region').order(nombre: :asc) }
  scope :geojson, ->(region_id) { select('ST_AsGeoJSON(the_geom) AS geojson').where(anpestid: region_id) }
end