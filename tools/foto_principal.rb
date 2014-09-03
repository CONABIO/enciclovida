require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Importa la foto principal de los taxones a la tabla especies para un manejo facil y rapido

*** Este script es para poner el la primera foto (si tiene) en la tabla de especies

Usage:

  rails r tools/foto_principal.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def system_call(cmd)
  puts "Ejecutando: #{cmd}" if OPTS[:debug]
  system cmd
end

def foto_principal
  puts 'Procesando los taxones...' if OPTS[:debug]

  #Especie.limit(100).each do |taxon|
  Especie.find_each do |taxon|
    next unless taxon.foto_principal.blank?
    next unless photo = taxon.photos.first

    taxon.foto_principal = photo.thumb_url
    taxon.save if taxon.changed?
  end
end

start_time = Time.now
puts 'Iniciando la importacion de la foto principal...' if OPTS[:debug]
foto_principal
puts "Termino la importacion de la foto principal en #{Time.now - start_time} seg" if OPTS[:debug]