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
  Especie.find_each do |taxon|
    puts "#{taxon.id}-#{taxon.nombre_cientifico}"
    taxon.completa_blurrily
  end

  puts 'Exportando nombres comunes ... ' if OPTS[:debug]
  NombreComun.find_each do |nom|
    puts "#{nom.id}-#{nom.nombre_comun}"
    nom.completa_blurrily
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
