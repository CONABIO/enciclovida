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

def system_call(cmd)
  puts "Ejecutando ... #{cmd}" if OPTS[:debug]
  system cmd
end

def exporta_a_blurrilly
  client_cientifico = Blurrily::Client.new(:host => CONFIG.ip, :db_name => 'nombres_cientificos')
  client_comun = Blurrily::Client.new(:host => CONFIG.ip, :db_name => 'nombres_comunes')

  puts 'Exportando nombres cientificos ... ' if OPTS[:debug]
  Especie.find_each do |taxon|
    client_cientifico.put(taxon.nombre_cientifico, taxon.id)
  end

  puts 'Exportando nombres comunes ... ' if OPTS[:debug]
  NombreComun.find_each do |nom|
    client_comun.put(nom.nombre_comun, nom.id)
  end
end

def creando_carpeta
  puts "Creando carpeta \"#{@path}\" si es que no existe..." if OPTS[:debug]
  Dir.mkdir(@path, 0755) if !File.exists?(@path)
end

start_time = Time.now

@path = 'db/blurrily'
creando_carpeta
exporta_a_blurrilly

puts "Exporto #{@file_path} en #{Time.now - start_time} seg" if OPTS[:debug]
