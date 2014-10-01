require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Completa el campo ancestry_ascendente_directo.

*** Este script tiene que correrse cada vez que se ingresa una nueva base.


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
    if e.id_nombre_ascendente != e.id
      e.ancestry_ascendente_directo="#{e.id_nombre_ascendente}"
      valor=true
      id=e.id_nombre_ascendente

      while valor do
        subEsp=EspecieBio.find(id)

        if subEsp.id_nombre_ascendente == subEsp.id
          valor=false
        else
          e.ancestry_ascendente_directo="#{subEsp.id_nombre_ascendente}/#{e.ancestry_ascendente_directo}"
          id=subEsp.id_nombre_ascendente
        end
      end

      e.save
    else
      puts 'Es root' if OPTS[:debug]
    end
  end
end

#antes de correr se tiene que comentar la linea de ancestry en el model

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
