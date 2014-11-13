require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Guarda en la base el kml para una facil consulta y generacion del mismo

Usage:

rails r tools/crea_kml.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def kml
#Especie.find_each do |taxon|
  Especie.limit(400).each do |taxon|
    puts "#{taxon.id}\t#{taxon.nombre}" if OPTS[:debug]
    next unless taxon.species_or_lower?
    proveedor = taxon.proveedor

    next unless proveedor
    proveedor.kml

    if proveedor.snib_kml.present? && proveedor.snib_kml_changed?
      puts "\tCon KML" if OPTS[:debug]
      proveedor.save
    end
  end
end


start_time = Time.now

@path = 'tools/bitacoras/datos_para_catalogos'
kml

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]