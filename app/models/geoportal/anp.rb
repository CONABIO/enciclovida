class Geoportal::Anp < GeoportalAbs

  self.table_name = 'anpestat'
  self.primary_key = 'anpestid'

  scope :campos_min, -> { select('anpestid AS region_id, CONCAT(nombre, \', \', cat_manejo) AS nombre_region').order(nombre: :asc) }
  scope :centroide, -> { select('st_x(st_centroid(geom)) AS long, st_y(st_centroid(geom)) AS lat') }
  scope :geojson_select, -> { select('ST_AsGeoJSON(geom) AS geojson') }
  scope :campos_geom, -> { centroide.geojson_select }
  scope :geojson, ->(region_id) { geojson_select.where(anpestid: region_id) }

end