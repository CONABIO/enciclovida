class Municipio < Snib

  self.primary_key = 'munid'

  scope :campos_min, -> { select('munid AS region_id, nom_mun AS nombre_region').order(nom_mun: :asc).group(:munid) }
  scope :centroide, -> { select('st_x(st_centroid(geom)) AS long, st_y(st_centroid(geom)) AS lat') }
  scope :bounds_select, -> { select('ST_Extent(geom) AS bounds') }
  scope :geojson_select, -> { select('ST_AsGeoJSON(geom) AS geojson') }
  scope :campos_geom, -> { centroide.geojson_select.bounds_select }
  scope :geojson, ->(region_id) { geojson_select.where(munid: region_id) }

end