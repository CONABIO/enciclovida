require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Completa el campo ancestry_ascendente_obligatorio.

*** Este script tiene que correrse cada vez que se ingresa una nueva base.


Usage:

  rails r tools/ancestry_ascendente_obligatorio_sql.rb -d
  rails r tools/ancestry_ascendente_obligatorio_sql.rb -d 02-Arthropoda    #para correr solo un conjunto de bases

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def completa
  EspecieBio.order('Nombre ASC').find_each do |e|
    puts e.nombre if OPTS[:debug]
    if e.id_ascend_obligatorio != e.id
      e.ancestry_ascendente_obligatorio="#{e.Iid_ascend_obligatorio}"
      valor=true
      id=e.id_ascend_obligatorio

      while valor do
        subEsp=EspecieBio.find(id)

        if subEsp.id_ascend_obligatorio == subEsp.id
          valor=false
        else
          e.ancestry_ascendente_obligatorio="#{subEsp.id_ascend_obligatorio}/#{e.ancestry_ascendente_obligatorio}"
          id=subEsp.id_ascend_obligatorio
        end
      end

      e.save
    else
      puts 'Es root' if OPTS[:debug]
    end
  end
end

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
    completa
  end
end
