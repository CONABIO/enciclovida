require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Guarda en la base el kml y crea el kmz para una facil consulta y generacion del mismo

*** Este script se deberia correr cada 1-2 semanas generar los kml y los kmz

Usage:

rails r tools/crea_kmz_naturalista.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def kml
  Proveedor.where('naturalista_obs IS NOT NULL').find_each do |proveedor|
    next unless taxon = proveedor.especie  # Por los IDS que borraron
    Rails.logger.debug "#{taxon.id}-#{taxon.nombre_cientifico}" if OPTS[:debug]
    next unless taxon.especie_o_inferior?
    proveedor.kml_naturalista

    if proveedor.naturalista_kml.present?
      Rails.logger.debug "\tCon KML" if OPTS[:debug]
      if proveedor.kmz_naturalista
        Rails.logger.debug "\t\tGuardo KMZ" if OPTS[:debug]
      end
    end
  end
end


start_time = Time.now

kml

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]
