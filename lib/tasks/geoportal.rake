require "#{Rails.root}/lib/geo_a_topo.rb"
namespace :geoportal do

  # Todos los rakes del redis en el groportal
  namespace :redis do
    desc "Genera/actualiza los estados en la base de redis"
    task estado: :environment do
      Geoportal::Estado.campos_min.campos_geom.all.each do |estado|
        estado.borra_redis
        estado.guarda_redis
      end
    end

    desc "Genera/actualiza los municipios en la base de redis"
    task municipio: :environment do
      Geoportal::Municipio.campos_min.campos_geom.all.each do |municipio|
        municipio.borra_redis
        municipio.guarda_redis
      end
    end

    desc "Genera/actualiza las ANPs en la base de redis"
    task anp: :environment do
      Geoportal::Anp.campos_min.campos_geom.all.each do |anp|
        anp.borra_redis
        anp.guarda_redis
      end
    end

    desc "Genera/actualiza los estados, municipios y ANPs en la base de redis"
    task todos: :environment do
      regiones = %w(estado municipio anp)
      
      regiones.each do |region|
        Geoportal.const_get(region.camelize).campos_min.campos_geom.all.each do |reg|
          reg.borra_redis
          reg.guarda_redis
        end
      end
    end
  end

  # Todos los rakes del topojson en el geoportal
  namespace :topojson do
    desc "Genera/actualiza los topojson de los estados"
    task estado: :environment do
      geo = GeoAtopo.new
      geo.topojson_por_region('estado')
    end

    desc "Genera/actualiza los topojson de los municipios"
    task municipio: :environment do
      geo = GeoAtopo.new
      geo.topojson_por_region('municipio')
    end

    desc "Genera/actualiza los topojson de las ANPs"
    task anp: :environment do
      geo = GeoAtopo.new
      geo.topojson_por_region('anp')
    end

    desc "Genera/actualiza los topojson de los estados, municipios y ANPs"
    task todos: :environment do
      regiones = %w(estado municipio anp)
      
      regiones.each do |region|
        geo = GeoAtopo.new
        geo.topojson_por_region(region)
      end
    end
  end
  
end
