require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Exporta todas las tuplas de la base al servidor blurrilly:

Usage:

  rails r tools/exporta_blurrily.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def exporta_a_blurrilly
  puts 'Exportando nombres cientificos ... ' if OPTS[:debug]
  client_cientifico = Blurrily::Client.new(:host => CONFIG.ip, :db_name => 'nombres_cientificos')
  client_comun = Blurrily::Client.new(:host => CONFIG.ip, :db_name => 'nombres_comunes')

  Especie.find_each do |taxon|
    puts "#{taxon.id}-#{taxon.nombre_cientifico}"
    client_cientifico.put(taxon.nombre_cientifico, taxon.id)
  end

  puts 'Exportando nombres comunes ... ' if OPTS[:debug]
  NombreComun.find_each do |nom|
    puts "#{nom.id}-#{nom.nombre_comun}"
    client_comun.put(nom.nombre_comun, nom.id)
  end
end

def creando_carpeta
  puts "Creando carpeta \"#{@path}\" si es que no existe..." if OPTS[:debug]
  Dir.mkdir(@path, 0755) unless File.exists?(@path)
end


start_time = Time.now

@path = 'db/blurrily'
creando_carpeta
exporta_a_blurrilly

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]
