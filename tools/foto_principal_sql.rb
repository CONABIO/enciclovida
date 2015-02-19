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
  Especie.find_each do |taxon|
  #Especie.limit(30).each do |taxon|
    #next unless taxon.id > 6011411
    puts "#{taxon.id}-#{taxon.nombre_cientifico}" if OPTS[:debug]
    next unless taxon.foto_principal.blank?  # Para evitar que la fotografia cambie cuando hacemos una migracion de bases

    taxon.pon_foto_principal
  end
end


start_time = Time.now

foto_principal

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]
