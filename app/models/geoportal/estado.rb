class Geoportal::Estado < GeoportalAbs

  self.primary_key = 'entid'

  scope :campos_min, -> { select('entid AS region_id, entidad').order(entidad: :asc) }
  scope :centroide, -> { select('st_x(st_centroid(the_geom)) AS long, st_y(st_centroid(the_geom)) AS lat') }
  scope :geojson_select, -> { select('ST_AsGeoJSON(the_geom) AS geojson') }
  scope :campos_geom, -> { centroide.geojson_select }
  scope :geojson, ->(region_id) { geojson_select.where(entid: region_id) }

  def nombre_publico
    I18n.t("estados.#{entidad.estandariza.gsub('-', '_')}")
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
    self.redis[:data][:id] = entid
    self.redis[:data][:nombre] = nombre_publico

    redis.deep_stringify_keys!
  end

  # Arma el ID de redis
  def asigna_redis_id
    # El 2 inicial es para saber que es un region
    # El 0 en la segunda posicion denota que es un estado
    # Y despues se ajusta a 8 digitos el numero de estado, para dar un total de 10 digitos
    self.redis = {} unless redis.present?
    self.redis["id"] = "20#{entid.to_s.rjust(8,'0')}".to_i
  end

end