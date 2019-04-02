class GeoportalAbs < ActiveRecord::Base

  self.abstract_class = true
  establish_connection(:geoportal)

  attr_accessor :redis, :loader

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

end