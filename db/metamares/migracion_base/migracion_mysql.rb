require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Completa el campo ancestry.

*** Popula la base de datos metamares con una tabla llamada "metadata" que son datos de su excel,
*** Correr este script si se desea migrar de nuevo hay que trucar las tablas de metamares o subir un respaldo limpio

Usage:

  rails r db/metamares/migracion_base/migracion.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def itera_metadata

end


start_time = Time.now

itera_metadata

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]