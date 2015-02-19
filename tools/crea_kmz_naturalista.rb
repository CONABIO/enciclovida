require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Guarda en la base el kml y crea el kmz para una facil consulta y generacion del mismo

*** Este script se corre cada semana para generar los kml y los kmz

Usage:

rails r tools/crea_kmz_naturalista.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def kml
  Proveedor.where('naturalista_obs IS NOT NULL').find_each do |proveedor|
    taxon = proveedor.especie
    #next unless taxon.id > 8010026
    puts "#{taxon.id}-#{taxon.nombre_cientifico}" if OPTS[:debug]
    proveedor.kml_naturalista

    if proveedor.naturalista_kml.present? && proveedor.naturalista_kml_changed?
      puts "\tCon KML" if OPTS[:debug]
      if proveedor.save
        if proveedor.kmz_naturalista
          puts "\t\tGuardo KMZ" if OPTS[:debug]
        end
      end
    end
  end
end


start_time = Time.now

kml

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]
