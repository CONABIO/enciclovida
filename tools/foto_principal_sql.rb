require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Importa la foto principal de los taxones a la tabla especies para un manejo facil y rapido

*** Este script es para poner el la primera foto (si tiene) en la tabla de especies

Usage:

  rails r tools/foto_principal_sql.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def foto_principal
  #Especie.limit(5).each do |taxon|
  Especie.find_each do |taxon|
    puts taxon.nombre if OPTS[:debug]
    next unless taxon.foto_principal.blank?
    taxon_bio = ''

    if taxon.photos.first
      photo = taxon.photos.first.thumb_url ||= '/assets/app/iconic_taxa/mammalia-75px.png'
      id=Bases.cual?(taxon.id)     #el ID de la base correspondiente
      taxon_bio = EspecieBio.find(id)
      taxon_bio.foto_principal = photo
    else
      id=Bases.cual?(taxon.id)
      taxon_bio = EspecieBio.find(id)
      puts "---#{taxon_bio.id}---" if OPTS[:debug]
      taxon_bio.foto_principal = '/assets/app/iconic_taxa/mammalia-75px.png'
    end
    taxon_bio.save if taxon_bio.changed?
    ActiveRecord::Base.establish_connection Rails.env
  end
end

start_time = Time.now
puts 'Iniciando la importacion de la foto principal...' if OPTS[:debug]
foto_principal
puts "Termino la importacion de la foto principal en #{Time.now - start_time} seg" if OPTS[:debug]