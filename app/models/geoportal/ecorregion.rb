class Ecorregion < Snib

  self.table_name = 'ecorregiones1'
  self.primary_key = 'ecorid'

  scope :campos_min, -> { select('ecorid AS region_id, desecon1 AS nombre_region').order(desecon1: :asc) }
  scope :centroide, -> { select('st_x(st_centroid(the_geom)) AS long, st_y(st_centroid(the_geom)) AS lat') }
  scope :geojson_select, -> { select('ST_AsGeoJSON(the_geom) AS geojson') }
  scope :campos_geom, -> { centroide.geojson_select }
  scope :geojson, ->(region_id) { geojson_select.where(ecorid: region_id) }

end