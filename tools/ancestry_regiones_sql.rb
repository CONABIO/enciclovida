require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Completa el campo ancestry.

*** Este script tiene que correrse cada vez que se ingresa una nueva base


Usage:

  rails r tools/ancestry_regiones_sql.rb -d
  rails r tools/ancestry_regiones_sql.rb -d 02-Arthropoda    #para correr solo un conjunto de bases

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def completa
  RegionBio.find_each do |r|
    puts r.nombre_region if OPTS[:debug]
    if r.id_region_asc != r.id
      r.ancestry=r.id_region_asc
      valor=true
      id=r.id_region_asc

      while valor do
        subReg=RegionBio.find(id)

        if subReg.id_region_asc == subReg.id
          valor=false
        else
          r.ancestry="#{subReg.id_region_asc}/#{r.ancestry}"
          id=subReg.id_region_asc
        end
      end

      r.save
    else
      puts 'Es root' if OPTS[:debug]
    end
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