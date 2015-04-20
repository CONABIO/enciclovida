#! /usr/local/bin/ruby
require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Borra los reinos vacios y pone el campo de referencia del ancestry en uno solo.

*** Este script puede usuarse para crear los campos adicionales o quitarlos.


Usage:

  rails r tools/quita_reinos_repetidos.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def quita_reinos_vacios

  # Al final los reinos unicos quedarian: 1000001,3000004,6000002,7000003,7000005
  sql = 'DELETE FROM especies WHERE id IN ('
  sql << '1000002,1000003,1000004,1000005,'
  sql << '2000001,2000002,2000003,2000004,2000005,'
  sql << '3000002,3000003,3000001,3000005,'
  sql << '4000001,4000002,4000003,4000004,4000005,'
  sql << '5000001,5000002,5000003,5000004,5000005,'
  sql << '6000001,6000003,6000004,6000005,'
  sql << '7000001,7000002,7000004,'
  sql << '8000001,8000002,8000003,8000004,8000005,'
  sql << '9000001,9000002,9000003,9000004,9000005,'
  sql << '10000002,10000003,10000004,10000005'
  sql << ')'
end

def actualiza_ancestry
  querys = []

  animalia_millones = 'UPDATE especies SET '
  animalia_millones << "ancestry_ascendente_directo='1000001'+SUBSTRING(ancestry_ascendente_directo,9, 200),"
  animalia_millones << "ancestry_ascendente_obligatorio='10000001'+SUBSTRING(ancestry_ascendente_directo,9, 200) "
  animalia_millones << "WHERE SUBSTRING(ancestry_ascendente_directo,1, 8) LIKE '_0000001%'"
  querys << animalia_millones

  animalia = 'UPDATE especies SET '
  animalia << "ancestry_ascendente_directo='1000001'+SUBSTRING(ancestry_ascendente_directo,9, 200),"
  animalia << "ancestry_ascendente_obligatorio='10000001'+SUBSTRING(ancestry_ascendente_directo,9, 200) "
  animalia << "WHERE SUBSTRING(ancestry_ascendente_directo,1, 8) LIKE '_000001%'"
  querys << animalia

  plantae = 'UPDATE especies SET '
  plantae << "ancestry_ascendente_directo='6000002'+SUBSTRING(ancestry_ascendente_directo,9, 200),"
  plantae << "ancestry_ascendente_obligatorio='60000002'+SUBSTRING(ancestry_ascendente_directo,9, 200) "
  plantae << "WHERE SUBSTRING(ancestry_ascendente_directo,1, 8) LIKE '_000002%'"
  querys << plantae

  prokaryote = 'UPDATE especies SET '
  prokaryote << "ancestry_ascendente_directo='7000003'+SUBSTRING(ancestry_ascendente_directo,9, 200),"
  prokaryote << "ancestry_ascendente_obligatorio='70000003'+SUBSTRING(ancestry_ascendente_directo,9, 200) "
  prokaryote << "WHERE SUBSTRING(ancestry_ascendente_directo,1, 8) LIKE '_000003%'"
  querys << prokaryote

  fungi = 'UPDATE especies SET '
  fungi << "ancestry_ascendente_directo='3000004'+SUBSTRING(ancestry_ascendente_directo,9, 200),"
  fungi << "ancestry_ascendente_obligatorio='30000004'+SUBSTRING(ancestry_ascendente_directo,9, 200) "
  fungi << "WHERE SUBSTRING(ancestry_ascendente_directo,1, 8) LIKE '_000004%'"
  querys << fungi

  proctoctista = 'UPDATE especies SET '
  proctoctista << "ancestry_ascendente_directo='7000005'+SUBSTRING(ancestry_ascendente_directo,9, 200),"
  proctoctista << "ancestry_ascendente_obligatorio='70000005'+SUBSTRING(ancestry_ascendente_directo,9, 200) "
  proctoctista << "WHERE SUBSTRING(ancestry_ascendente_directo,1, 8) LIKE '_000005%'"
  querys << proctoctista

  querys
end


start_time = Time.now

#Se coore como SQL directo para saltarse las validaciones de los modelos.
actualiza_ancestry.each do |query|
  puts "Ejecutando: #{query}" if OPTS[:debug]
  Bases.ejecuta query
end
puts 'Quitando los reinos vacios' if OPTS[:debug]
Bases.ejecuta quita_reinos_vacios

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]