class Ecorregion < ActiveRecord::Base
  establish_connection(:snib)
  self.table_name = 'ecorregiones1'
  self.primary_key = 'ecorid'

  scope :campos_min, -> { select('ecorid AS region_id, desecon1 AS nombre_region').order(desecon1: :asc) }
  scope :geojson, ->(region_id) { select('ST_AsGeoJSON(the_geom) AS geojson').where(ecorid: region_id) }
end