require 'rubygems'
require 'trollop'
require 'rest_client'
require 'json'

OPTS = Trollop::options do
  banner <<-EOS
Importa los ID's de NaturaLista y la informacion hacia tools/bitacoras/info_naturalista/arch.json,
 para un manejo mas rapido entre la informacion.

*** En caso de estar en SQL Server, el volcado es necesario para esta accion

Usage:

  rails r tools/informacion_naturalista.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def search
  Especie.find_each do |t|
    #Especie.limit(10).each do |t|
    next unless t.id > 10016523
    puts "#{t.id}-#{t.nombre_cientifico}" if OPTS[:debug]

    if proveedor = t.proveedor
      puts "\tYa se registro ese ID" if OPTS[:debug]
      proveedor.info_naturalista
    else
      puts "\tAun no se ha registrado ese ID" if OPTS[:debug]
      proveedor = Proveedor.crea_info_naturalista(t)
    end

    if proveedor.instance_of?(Proveedor)
      if proveedor.changed?
        if proveedor.save
          puts "\t\tGuardo la informacion" if OPTS[:debug]
        else
          puts "\t\tNo pudo guardar la informacion" if OPTS[:debug]
        end
      else
        puts "\t\tNo hubo cambios" if OPTS[:debug]
      end
    else
      puts "\t\tNo existe informacion en NaturaLista" if OPTS[:debug]
    end
    #sleep 1
  end
end


start_time = Time.now

search

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]
