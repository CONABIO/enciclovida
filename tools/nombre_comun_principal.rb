require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Importa los nombres comunes de los taxones a la tabla especies para un manejo facil y rapido

*** Este script es para poner el nombre comun principal en la tabla de especies

Usage:

  rails r tools/nombre_comun_principal.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def system_call(cmd)
  puts "Ejecutando: #{cmd}" if OPTS[:debug]
  system cmd
end

def nom_com_principal
  puts 'Procesando los taxones...' if OPTS[:debug]

  #Especie.limit(100).each do |taxon|
  Especie.find_each do |taxon|
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
nom_com_principal
puts "Termino la importacion del nombre comun en #{Time.now - start_time} seg" if OPTS[:debug]