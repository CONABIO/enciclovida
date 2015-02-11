require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Importa los nombres comunes de los taxones a la tabla Nombre de una o mas bases para un manejo facil y rapido

*** Este script es para poner el nombre comun principal en la tabla de especies

Usage:

  rails r tools/nombre_comun_principal_sql.rb -d
  rails r tools/nombre_comun_principal_sql.rb -d 02-Arthropoda    #para correr solo un conjunto de bases

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def nom_com_principal
  puts 'Procesando los taxones...' if OPTS[:debug]

  EspecieBio.find_each do |taxon|
    puts "#{taxon.id}-#{taxon.nombre}" if OPTS[:debug]
    taxon.evita_before_save = true
    taxon.pon_nombre_comun_principal
    taxon.save if taxon.nombre_comun_principal_changed?
  end
end


start_time = Time.now

if ARGV.any?
  ARGV.each do |base|
    if CONFIG.bases.include?(base)
      Bases.conecta_a base
      puts "Conectando a: #{base}" if OPTS[:debug]
      nom_com_principal
    end
  end
else
  CONFIG.bases.each do |base|
    Bases.conecta_a base
    puts "Conectando a: #{base}" if OPTS[:debug]
    nom_com_principal
  end
end

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]