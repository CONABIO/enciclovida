class Geoportal::Ecorregion < GeoportalAbs

  self.table_name = 'ecorregiones'
  self.primary_key = 'gid'

  alias_attribute :region_id, :gid
  alias_attribute :nombre_region, :desecon3

  scope :campos_min, -> { select(:region_id, :nombre_region).order(nombre_region: :asc).group(:region_id) }

  def nombre_publico
    nombre_region
  end

  def tipo
    'Ecorregión'
  end


  private

  # Arma el ID de redis
  def asigna_redis_id
    # El 2 inicial es para saber que es un region
    # El 3 en la segunda posicion denota que es una ecorregion
    # Y despues se ajusta a 8 digitos, para dar un total de 10 digitos
    self.redis = {} unless redis.present?
    self.redis["id"] = "23#{region_id.to_s.rjust(8,'0')}".to_i
  end

end