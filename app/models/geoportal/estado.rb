class Estado < Geoportal

  self.primary_key = 'entid'

  scope :campos_min, -> { select('entid AS region_id, entidad AS nombre_region').order(entidad: :asc) }
  scope :centroide, -> { select('st_x(st_centroid(the_geom)) AS long, st_y(st_centroid(the_geom)) AS lat') }
  scope :geojson_select, -> { select('ST_AsGeoJSON(the_geom) AS geojson') }
  scope :campos_geom, -> { centroide.geojson_select }
  scope :geojson, ->(region_id) { geojson_select.where(entid: region_id) }

  attr_accessor :redis

  def asigna_redis
    self.redis = {}
    self.redis[:data] = {}

    # El 2 inicial es para saber que en un region
    # El 0 en la segunda posicion denota que es un estado
    # Y despues se ajusta a 8 digitos el numero de estado, para dar un total de 10 digitos
    datos[:id] = "20#{entid.to_s.rjust(8,'0')}".to_i
  end


  private

  def nombre_publico
    I18n.t("estados.#{entidad.estandariza.gsub('-', '_')}")
  end

end