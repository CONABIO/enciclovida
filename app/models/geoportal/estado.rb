class Geoportal::Estado < GeoportalAbs

  self.primary_key = 'entid'
  alias_attribute :region_id, :entid
  alias_attribute :nombre_region, :nom_ent

  scope :campos_min, -> { select(:region_id, :nombre_region).order(nombre_region: :asc).group(:region_id) }
  scope :centroide, -> { select('st_x(st_centroid(geom)) AS long, st_y(st_centroid(geom)) AS lat') }
  scope :bounds_select, -> { select('ST_Extent(geom) AS bounds') }
  scope :geojson_select, -> { select('ST_AsGeoJSON(geom) AS geojson') }
  scope :campos_geom, -> { centroide.geojson_select.bounds_select }

  def nombre_publico
    I18n.t("estados.#{nombre_region.estandariza.gsub('-', '_')}")
  end

  def tipo
    'Estado'
  end


  private

  def asigna_redis
    asigna_redis_id
    self.redis[:data] = {}
    self.redis[:term] = I18n.transliterate(nombre_publico.limpia).downcase
    self.redis[:score] = 1000
    self.redis[:data][:id] = region_id
    self.redis[:data][:nombre] = nombre_publico

    redis.deep_stringify_keys!
  end

  # Arma el ID de redis
  def asigna_redis_id
    # El 2 inicial es para saber que es un region
    # El 0 en la segunda posicion denota que es un estado
    # Y despues se ajusta a 8 digitos el numero de estado, para dar un total de 10 digitos
    self.redis = {} unless redis.present?
    self.redis["id"] = "20#{region_id.to_s.rjust(8,'0')}".to_i
  end

end