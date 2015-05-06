require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Importa los nombres comunes de los taxones a la tabla Nombre de una o mas bases para un manejo facil y rapido

*** Este script es para poner el nombre comun principal en la tabla de especies, tanto de catalogos como
*** de NaturaLista

Usage:

  rails r tools/nombre_comun_principal_sql.rb -d
  rails r tools/nombre_comun_principal_sql.rb -d 02-Arthropoda    #para correr solo un conjunto de bases

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def nom_com_principal(base)
  puts 'Procesando los taxones...' if OPTS[:debug]

  EspecieBio.find_each do |taxon|
    puts "#{taxon.id}-#{taxon.nombre}" if OPTS[:debug]
    next if taxon.nombre_comun_principal.present?   # Para no sobreescribir los cambios

    taxon.evita_before_save = true
    taxon.pon_nombre_comun_principal(base)
    Bases.conecta_a(base)  # Para no perder la conexion a la base original

    if taxon.nombre_comun_principal_changed?
      puts "\t#{taxon.nombre_comun_principal}"
      taxon.save
    end
  end
end


start_time = Time.now

if ARGV.any?
  ARGV.each do |base|
    if CONFIG.bases.include?(base)
      Bases.conecta_a base
      puts "Conectando a: #{base}" if OPTS[:debug]
      nom_com_principal(base)
    end
  end
else
  CONFIG.bases.each do |base|
    Bases.conecta_a base
    puts "Conectando a: #{base}" if OPTS[:debug]
    nom_com_principal(base)
  end
end

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]