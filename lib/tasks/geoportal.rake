namespace :geoportal do

  desc "Genera/actualiza los estados de la base del geoportal"
  task estados: :environment do
    Geoportal::Estado.all.each do |estado|
      estado.borra_redis
      estado.guarda_redis
    end
  end

  desc "Genera/actualiza los municipios de la base del geoportal"
  task municipios: :environment do
    Geoportal::Municipio.all.each do |municipio|
      municipio.borra_redis
      municipio.guarda_redis
    end
  end

  desc "Genera/actualiza las ANPs de la base del geoportal"
  task anps: :environment do
    Geoportal::Anp.all.each do |anp|
      anp.borra_redis
      anp.guarda_redis
    end
  end

end
