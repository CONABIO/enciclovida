class Estado < Snib

  self.primary_key = 'entid'

  scope :campos_min, -> { select('entid AS region_id, nom_ent AS nombre_region').order(nom_ent: :asc).group(:entid) }
  scope :centroide, -> { select('st_x(st_centroid(geom)) AS long, st_y(st_centroid(geom)) AS lat') }
  scope :bounds_select, -> { select('ST_Extent(geom) AS bounds') }
  scope :geojson_select, -> { select('ST_AsGeoJSON(geom) AS geojson') }
  scope :campos_geom, -> { centroide.geojson_select.bounds_select }
  scope :geojson, ->(region_id) { geojson_select.where(entid: region_id) }

end