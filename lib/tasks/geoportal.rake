require "#{Rails.root}/lib/geo_a_topo.rb"
namespace :geoportal do

  desc "Genera/actualiza los estados de la base del geoportal y crea el mapa con el topojson"
  task estados: :environment do
    Geoportal::Estado.all.each do |estado|
      estado.borra_redis
      estado.guarda_redis
    end

    geo = GeoAtopo.new
    geo.topojson_por_region('estado')
  end

  desc "Genera/actualiza los municipios de la base del geoportal y crea el mapa con el topojson"
  task municipios: :environment do
    Geoportal::Municipio.all.each do |municipio|
      municipio.borra_redis
      municipio.guarda_redis
    end

    geo = GeoAtopo.new
    geo.topojson_por_region('municipio')
  end

  desc "Genera/actualiza las ANPs de la base del geoportal y crea el mapa con el topojson"
  task anps: :environment do
    Geoportal::Anp.all.each do |anp|
      anp.borra_redis
      anp.guarda_redis
    end

    geo = GeoAtopo.new
    geo.topojson_por_region('anp')
  end

  desc "Genera/actualiza los estados, municipios y ANPs de la base del geoportal y crea los mapa con el topojson"
  task todos: :environment do
    regiones = %w(estado municipio anp)
    
    regiones.each do |region|
      "Geoportal::#{region.camelize}".constantize.all.each do |reg|
        reg.borra_redis
        reg.guarda_redis
      end

      geo = GeoAtopo.new
      geo.topojson_por_region(region)
    end
  end

end
