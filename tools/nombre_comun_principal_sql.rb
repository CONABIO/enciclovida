require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Importa los nombres comunes de los taxones a la tabla especies para un manejo facil y rapido

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
    puts taxon.nombre if OPTS[:debug]
    next unless taxon.nombre_comun_principal.blank?

    con_espaniol = false
    taxon.nombres_comunes.each do |nc|
      if !con_espaniol && nc.lengua == 'Español'
        taxon.nombre_comun_principal = nc.nombre_comun
        con_espaniol = true
      elsif !con_espaniol && nc.lengua == 'Inglés'
        taxon.nombre_comun_principal = nc.nombre_comun
      end
    end
    taxon.save if taxon.changed?
  end
end

start_time = Time.now
puts 'Iniciando la importacion del nombre comun principal...' if OPTS[:debug]

if ARGV.any?
  ARGV.each do |base|
    if CONFIG.bases.include?(base)
      ActiveRecord::Base.establish_connection base
      puts "Conectando a: #{base}" if OPTS[:debug]
      nom_com_principal
    end
  end
else
  CONFIG.bases.each do |base|
    ActiveRecord::Base.establish_connection base
    puts "Conectando a: #{base}" if OPTS[:debug]
    nom_com_principal
  end
end

puts "Termino la importacion del nombre comun en #{Time.now - start_time} seg" if OPTS[:debug]