require 'rubygems'
require 'trollop'
require 'rest_client'
require 'json'

OPTS = Trollop::options do
  banner <<-EOS
Importa los ID's de NaturaLista y la informacion hacia tools/bitacoras/info_naturalista/arch.json,
 para un manejo mas rapido entre la informacion.

*** En caso de estar en SQL Server, el volcado es necesario para esta accion

Usage:

  rails r tools/ids_naturalista.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def search
  Especie.find_each do |t|
  #Especie.limit(10).each do |t|
    puts "Procesando... #{t.nombre_cientifico}" if OPTS[:debug]
    #next if t.id <= 10033447

    proveedor = t.proveedor
    if proveedor
      puts "-->Ya se registro ese ID... #{t.nombre_cientifico}" if OPTS[:debug]
      response = RestClient.get "#{@site}/taxa/#{proveedor.naturalista_id}.json"
      data = JSON.parse(response)

      if data.present?    #solo para actualizar el json
        proveedor.naturalista_id = data.first['id']
        proveedor.naturalista_info = "#{data}"
        proveedor.save
        puts '----->La informacion existe...' if OPTS[:debug]
      else
        puts '----->La informacion NO existe...' if OPTS[:debug]
      end

    else
      puts "-->Aun no existe registro de ese ID... #{t.nombre_cientifico}" if OPTS[:debug]
      response = RestClient.get "#{@site}/taxa/search.json?q=#{URI.escape(t.nombre_cientifico)}"
      data = JSON.parse(response)
      exact_data = comprueba_nombre(t, data)
      if exact_data.present?
        #crea el proveedor a traves de la asociacion
        proveedor = Proveedor.new(:especie_id => t.id, :naturalista_id => exact_data.first['id'], :naturalista_info => "#{exact_data}")
        proveedor.save
        puts '----->La informacion existe...' if OPTS[:debug]
      else
        @bitacora_no_encontro.puts "#{t.id},#{t.nombre_cientifico}"    #en caso que ese nombre no exista en la base de NaturaLista
        puts '----->La informacion NO existe...' if OPTS[:debug]
      end
    end
    sleep 2
  end
end

def comprueba_nombre(taxon, data)
  data.each do |d|
    return d if d['name'] == taxon
  end
end

def creando_carpeta(path)
  puts "Creando carpeta \"#{path}\" si es que no existe..." if OPTS[:debug]
  Dir.mkdir(path, 0755) if !File.exists?(path)
end

def bitacoras
  puts 'Iniciando bitacoras ...' if OPTS[:debug]
  @bitacora_no_encontro = File.new("#{@path}/sin_ID_#{Time.now.strftime("%Y_%m_%d_%H-%M-%S")}_no_records.out", 'a+')
end


start_time = Time.now

@site = 'http://conabio.inaturalist.org'
@path = 'tools/bitacoras/info_naturalista'
bitacoras
creando_carpeta @path
search

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]