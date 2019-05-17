class Geoportal::Anp < GeoportalAbs

  self.table_name = 'anpestat'
  self.primary_key = 'anpestid'

  alias_attribute :region_id, :anpestid

  scope :campos_min, -> { select('anpestid, nombre, cat_manejo').order(nombre: :asc) }
  scope :centroide, -> { select('st_x(st_centroid(geom)) AS long, st_y(st_centroid(geom)) AS lat') }
  scope :geojson_select, -> { select('ST_AsGeoJSON(geom) AS geojson') }
  scope :campos_geom, -> { centroide.geojson_select }
  scope :geojson, ->(region_id) { geojson_select.where(anpestid: region_id) }

  def nombre_publico
    nombre
  end

  def tipo
    'ANP'
  end

  def tipo_region
    I18n.t("anps_tipos.#{cat_manejo.estandariza}")
  end


  private

  def asigna_redis
    asigna_redis_id
    self.redis[:data] = {}
    self.redis[:term] = nombre_publico.limpia.downcase
    self.redis[:score] = 10
    self.redis[:data][:id] = anpestid
    self.redis[:data][:nombre] = nombre_publico
    self.redis[:data][:tipo] = tipo
    self.redis[:data][:tipo_region] = tipo_region

    redis.deep_stringify_keys!
  end

  # Arma el ID de redis
  def asigna_redis_id
    # El 2 inicial es para saber que es un region
    # El 2 en la segunda posicion denota que es un estado
    # Y despues se ajusta a 8 digitos el numero de estado, para dar un total de 10 digitos
    self.redis = {} unless redis.present?
    self.redis["id"] = "22#{anpestid.to_s.rjust(8,'0')}".to_i
  end

end