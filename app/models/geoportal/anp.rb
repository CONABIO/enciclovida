class Geoportal::Anp < GeoportalAbs

  self.table_name = 'anp'

  alias_attribute :region_id, :anpid
  alias_attribute :nombre_region, :nombre

  scope :campos_min, -> { select(:region_id, :nombre_region, :cat_manejo).order(nombre_region: :asc).group(:region_id) }

  def nombre_publico
    "#{nombre_region}, #{tipo_region}"
  end

  def tipo
    'ANP'
  end

  def tipo_region
    I18n.t("anps_tipos.#{cat_manejo.estandariza}")
  end


  private

  # Arma el ID de redis
  def asigna_redis_id
    # El 2 inicial es para saber que es un region
    # El 2 en la segunda posicion denota que es una ANP
    # Y despues se ajusta a 8 digitos, para dar un total de 10 digitos
    self.redis = {} unless redis.present?
    self.redis["id"] = "22#{region_id.to_s.rjust(8,'0')}".to_i
  end

end