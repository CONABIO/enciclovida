class GeoportalAbs < ActiveRecord::Base

  self.abstract_class = true
  establish_connection(:geoportal)

  attr_accessor :redis, :loader

  scope :centroide, -> { select('st_x(st_centroid(geom)) AS long, st_y(st_centroid(geom)) AS lat') }
  scope :bounds_select, -> { select('ST_Extent(geom) AS bounds') }
  scope :geojson_select, -> { select('ST_AsGeoJSON(geom) AS geojson') }
  scope :campos_geom, -> { centroide.geojson_select.bounds_select }

  def bounds_formato
    bounds.gsub(/[BBOX()]/,'').split(',').map{ |a| a.split(' ').reverse.map{ |s| s.to_f } }
  end
  
  def asigna_redis
    asigna_redis_id
    self.redis[:data] = {}
    self.redis[:term] = I18n.transliterate(nombre_publico.limpia.downcase)
    self.redis[:score] = score_redis
    self.redis[:data][:region_id] = region_id
    self.redis[:data][:nombre_region] = nombre_publico
    self.redis[:data][:bounds] = bounds_formato
    self.redis[:data][:geojson] = asigna_pixi_geojson

    redis.deep_stringify_keys!
  end

  def guarda_redis
    asigna_loader
    asigna_redis
    loader.add(redis)
    Rails.logger.debug "[DEBUG] - Generando redis : #{redis}"
  end

  def borra_redis
    asigna_loader
    asigna_redis_id
    loader.remove(redis)
    Rails.logger.debug "[DEBUG] - Borrando redis : #{redis}"
  end


  private

  # Inicializa la base del loader
  def asigna_loader
    nombre_loader = self.class.name.demodulize.downcase
    self.loader = Soulmate::Loader.new(nombre_loader)
    Rails.logger.debug "[DEBUG] - Loader: #{loader.inspect}"
  end

  # define el score de redis de acuerdo a la region
  def score_redis
    case tipo.estandariza
    when 'estado'
      1000
    when 'municipio'
      100
    when 'anp'
      10
    end
  end

  # Lee el archivo json para asignarlo en el campo geojson
  def asigna_pixi_geojson
    file = File.read(Rails.root.join('public', 'topojson', "#{tipo.estandariza}.json"))
    json = JSON.parse(file)
    json[region_id.to_s]
  end

end