#! /usr/local/bin/ruby
require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Llena los campos icono y nombre_icono.

*** Este script debe usuarse cada vez que se cree el volcado.


Usage:

  rails r tools/grupos_iconicos.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def grupo_iconico
  Especie.find_each do |taxon|
    puts "#{taxon.id}-#{taxon.nombre}" if OPTS[:debug]

    adicional = taxon.asigna_nombre_comun

    if adicional[:cambio]
      puts "\t#{adicional[:adicional].icono}-#{adicional[:adicional].nombre_icono}-#{adicional[:adicional].color_icono}"
      adicional[:adicional].save
    end
  end
end


start_time = Time.now

grupo_iconico

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]