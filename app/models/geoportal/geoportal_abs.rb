class GeoportalAbs < ActiveRecord::Base

  self.abstract_class = true
  establish_connection(:geoportal)

  attr_accessor :redis, :loader

  def guarda_redis
    asigna_loader
    asigna_redis
    loader.add(redis)
  end

  def borra_redis
    asigna_loader
    asigna_redis_id
    loader.remove(redis)
  end

end