class Geoportal::Ecorregion < GeoportalAbs

  self.table_name = 'ecorregiones'
  self.primary_key = 'gid'

  alias_attribute :region_id, :gid

  scope :campos_min, -> { select('gid, desecon1').order(desecon1: :asc) }
  scope :centroide, -> { select('st_x(st_centroid(geom)) AS long, st_y(st_centroid(geom)) AS lat') }
  scope :geojson_select, -> { select('ST_AsGeoJSON(geom) AS geojson') }
  scope :campos_geom, -> { centroide.geojson_select }
  scope :geojson, ->(region_id) { geojson_select.where(region_id: region_id) }

  def nombre_publico
    desecon1
  end

  def tipo
    'Región ecológica'
  end

end