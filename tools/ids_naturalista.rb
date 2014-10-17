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
  json = ''
  #Especie.find_each do |taxon|
  Especie.limit(10).each do |t|
    puts "Procesando... #{t.nombre_cientifico}" if OPTS[:debug]

    next unless !t.nombre_cientifico.include?('(')  #existen unos taxones con una estructura erronea

    proveedor = t.proveedor
    if proveedor
      puts "Ya se registro ese ID... #{t.nombre_cientifico}" if OPTS[:debug]
      response = RestClient.get "#{@site}/taxa/#{proveedor.naturalista_id}.json"
      data = JSON.parse(response)
      json+= "\"#{t.id}\":#{response}," if data.present?    #solo para actualizar el json

    else
      puts "Aun no existe registro de ese ID... #{t.nombre_cientifico}" if OPTS[:debug]
      response = RestClient.get "#{@site}/taxa/search.json?q=#{t.nombre_cientifico.parameterize.gsub('-', ' ')}"
      data = JSON.parse(response)
      if data.present? && data.count == 1
        json+= "\"#{t.id}\":#{response},"
        proveedor.create(:naturalista_id => data.first['id'])   #crea el proveedor a traves de la asociacion
        proveedor.save
      else
        @bitacora_no_encontro.puts "#{t.id},#{t.nombre_cientifico}"    #en caso que ese nombre no exista en la base de NaturaLista
      end
    end
  end

  @bitacora.puts "{#{json[0..-2]}}"
end

def creando_carpeta(path)
  puts "Creando carpeta \"#{path}\" si es que no existe..." if OPTS[:debug]
  Dir.mkdir(path, 0755) if !File.exists?(path)
end

def bitacoras
  puts 'Iniciando bitacoras ...' if OPTS[:debug]
  @bitacora = File.new("#{@path}/record_taxa_#{Time.now.strftime("%Y_%m_%d_%H-%M-%S")}.json", 'w')
  @bitacora_no_encontro = File.new("#{@path}/sin_ID_#{Time.now.strftime("%Y_%m_%d_%H-%M-%S")}_no_records.out", 'a+')
end


start_time = Time.now

bitacoras
@site = 'http://conabio.inaturalist.org'
@path = 'tools/bitacoras/info_naturalista'
creando_carpeta @path
search

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]