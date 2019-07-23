require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Crea el archivo en geodatos que contiene todos los registros del SNIB y Naturalista por especie


*** Este script solo es necesario correrlo una vez, ya que se actualiza en los delayed jobs

Usage:

  rails r tools/genera_archivo_registros_todos.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end


def genera_registros
  Rails.logger.debug 'Procesando los nombres cientificos...' if OPTS[:debug]

  Especie.find_each do |t|
    puts "\t#{t.id}-#{t.nombre_cientifico}"
    next unless t.apta_con_geodatos?

    if p = t.proveedor
      puts "\t\t#Tuvo proveedor" if OPTS[:debug]
      res = p.guarda_registros_todos

      if res[:estatus]
        puts "\t\t\t#Genero archivo de registros" if OPTS[:debug]
      else
        puts "\t\t\t#No hubo registros" if OPTS[:debug]
      end
    end
  end
end


start_time = Time.now

genera_registros

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]