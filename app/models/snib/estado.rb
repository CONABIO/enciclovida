class Estado < ActiveRecord::Base
  establish_connection(:snib)
  self.primary_key = 'entid'

  scope :campos_min, -> { select('entid AS region_id, entidad AS nombre_region').order(entidad: :asc) }
  scope :geojson, ->(region_id) { select('ST_AsGeoJSON(the_geom) AS geojson').where(entid: region_id) }
end