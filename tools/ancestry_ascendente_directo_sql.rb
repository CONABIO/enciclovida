require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Completa el campo ancestry_ascendente_directo.

*** Este script tiene que correrse cada vez que se ingresa una nueva base


Usage:

  rails r tools/ancestry_ascendente_directo_sql.rb -d
  rails r tools/ancestry_ascendente_directo_sql.rb -d 02-Arthropoda    #para correr solo un conjunto de bases

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def completa
  EspecieBio.order('Nombre ASC').find_each do |e|
    puts e.nombre if OPTS[:debug]
    e.ancestry_directo
    e.evita_before_save = true        # evita el metodo before_save
    e.avoid_ancestry = true           # evita la gema ancestry
    e.save
  end
end

#*******antes de correr se tiene que comentar la linea de ancestry en el model**********

start_time = Time.now

if ARGV.any?
  ARGV.each do |base|
    if CONFIG.bases.include?(base)
      ActiveRecord::Base.establish_connection base
      puts "Conectando a: #{base}" if OPTS[:debug]
      completa
    end
  end
else
  CONFIG.bases.each do |base|
    ActiveRecord::Base.establish_connection base
    puts "Conectando a: #{base}" if OPTS[:debug]
    completa
  end
end

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]