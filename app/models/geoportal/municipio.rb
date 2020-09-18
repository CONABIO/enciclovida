class Geoportal::Municipio < GeoportalAbs
  
  self.primary_key = 'munid'
  alias_attribute :region_id, :munid
  alias_attribute :nombre_region, :nom_mun
  alias_attribute :nombre_estado, :nom_ent

  scope :campos_min, -> { select(:region_id, :nombre_region, :nombre_estado).order(nombre_region: :asc).group(:region_id) }

  def nombre_publico
    "#{nombre_region}, #{I18n.t("estados.#{nombre_estado.estandariza.gsub('-', '_')}")}"
  end

  def tipo
    'Municipio'
  end


  private

  def asigna_redis
    asigna_redis_id
    self.redis[:data] = {}
    self.redis[:term] = I18n.transliterate(nombre_publico.limpia.downcase)
    self.redis[:score] = 100
    self.redis[:data][:id] = region_id
    self.redis[:data][:nombre] = nombre_publico

    redis.deep_stringify_keys!
  end

  # Arma el ID de redis
  def asigna_redis_id
    # El 2 inicial es para saber que es un region
    # El 1 en la segunda posicion denota que es un municipio
    # Y despues se ajusta a 8 digitos, para dar un total de 10 digitos
    self.redis = {} unless redis.present?
    self.redis["id"] = "21#{region_id.to_s.rjust(8,'0')}".to_i
  end

end