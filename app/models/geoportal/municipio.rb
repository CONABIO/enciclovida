class Geoportal::Municipio < GeoportalAbs

  alias_attribute :region_id, :munid

  scope :campos_min, -> { select('munid, nom_mun, nom_ent').order(nom_mun: :asc) }
  scope :centroide, -> { select('st_x(st_centroid(geom)) AS long, st_y(st_centroid(geom)) AS lat') }
  scope :geojson_select, -> { select('ST_AsGeoJSON(geom) AS geojson') }
  scope :campos_geom, -> { centroide.geojson_select }
  scope :geojson, ->(region_id) { geojson_select.where(region_id: region_id) }

  def nombre_publico
    "#{nom_mun}, #{I18n.t("estados.#{nom_ent.estandariza.gsub('-', '_')}")}"
  end

  def tipo
    'Municipio'
  end


  private

  def asigna_redis
    asigna_redis_id
    self.redis[:data] = {}
    self.redis[:term] = I18n.transliterate(municipio.limpia.downcase)
    self.redis[:score] = 100
    self.redis[:data][:id] = region_id
    self.redis[:data][:nombre] = nombre_publico

    redis.deep_stringify_keys!
  end

  # Arma el ID de redis
  def asigna_redis_id
    # El 2 inicial es para saber que es un region
    # El 1 en la segunda posicion denota que es un estado
    # Y despues se ajusta a 8 digitos el numero de estado, para dar un total de 10 digitos
    self.redis = {} unless redis.present?
    self.redis["id"] = "21#{region_id.to_s.rjust(8,'0')}".to_i
  end

end