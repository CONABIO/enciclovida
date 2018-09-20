class Anp < Snib

  #establish_connection(:snib)
  self.table_name = 'anpestat'
  self.primary_key = 'anpestid'

  scope :campos_min, -> { select('anpestid AS region_id, CONCAT(nombre, \', \', entidad) AS nombre_region').order(nombre: :asc) }
  scope :centroide, -> { select('st_x(st_centroid(the_geom)) AS long, st_y(st_centroid(the_geom)) AS lat') }
  scope :geojson_select, -> { select('ST_AsGeoJSON(the_geom) AS geojson') }
  scope :campos_geom, -> { centroide.geojson_select }
  scope :geojson, ->(region_id) { geojson_select.where(anpestid: region_id) }

end