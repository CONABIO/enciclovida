require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Importa los nombres comunes de los taxones a la tabla adicionales de la base principal, una vez creado el volcado

*** Este script es para poner el nombre comun principal en la tabla de especies, tanto de catalogos como de NaturaLista

Usage:

  rails r tools/nombre_comun_principal.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def nom_com_principal
  puts 'Procesando los taxones...' if OPTS[:debug]

  Especie.find_each do |taxon|
    puts "#{taxon.id}-#{taxon.nombre}" if OPTS[:debug]

    adicional = taxon.asigna_nombre_comun

    if adicional[:cambio]
      puts "\t#{adicional[:adicional].nombre_comun_principal}"
      adicional[:adicional].save
    end
  end
end


start_time = Time.now

nom_com_principal

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]