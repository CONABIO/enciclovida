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
  Rails.logger.debug 'Exportando nombres cientificos ... ' if OPTS[:debug]
  client_cientifico = Blurrily::Client.new(:host => IP, :db_name => 'nombres_cientificos')
  client_comun = Blurrily::Client.new(:host => IP, :db_name => 'nombres_comunes')

  Especie.find_each do |taxon|
    Rails.logger.debug "#{taxon.id}-#{taxon.nombre_cientifico}"
    client_cientifico.put(taxon.nombre_cientifico, taxon.id)
  end

  Rails.logger.debug 'Exportando nombres comunes ... ' if OPTS[:debug]
  NombreComun.find_each do |nom|
    Rails.logger.debug "#{nom.id}-#{nom.nombre_comun}"
    client_comun.put(nom.nombre_comun, nom.id)
  end
end

def creando_carpeta
  Rails.logger.debug "Creando carpeta \"#{@path}\" si es que no existe..." if OPTS[:debug]
  Dir.mkdir(@path, 0755) unless File.exists?(@path)
end

def delete_files
  Rails.logger.debug 'Eliminando archivos anteriores...' if OPTS[:debug]
  f_cien="#{@path}/nombres_cientificos.trigrams"
  f_com="#{@path}/nombres_comunes.trigrams"

  File.delete(f_cien) if File.exists?(f_cien)
  File.delete(f_com) if File.exists?(f_com)
end


start_time = Time.now

@path = 'db/blurrily'
creando_carpeta
delete_files
exporta_a_blurrilly

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]
