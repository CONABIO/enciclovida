require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Guarda en la base el kml y crea el kmz para una facil consulta y generacion del mismo

*** Este script se deberia correr cada semana para generar los kml y los kmz

Usage:

rails r tools/crea_kmz_snib.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def kmz
  Proveedor.where('snib_id IS NOT NULL').find_each do |proveedor|
    next unless taxon = proveedor.especie  # Por los IDS que borraron
    Rails.logger.debug "#{taxon.id}-#{taxon.nombre_cientifico}" if OPTS[:debug]

    next unless taxon.especie_o_inferior?
    proveedor.kml

    if proveedor.snib_kml.present?
      Rails.logger.debug "\tCon KML" if OPTS[:debug]
      if proveedor.kmz
        Rails.logger.debug "\t\tCon KMZ" if OPTS[:debug]
      end
    end
  end
end


start_time = Time.now

kmz

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]
