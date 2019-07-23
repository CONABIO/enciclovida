require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Completa el campo ancestry.

*** Este script tiene que correrse cada vez que se ingresa una nueva base


Usage:

  rails r tools/ancestry_regiones.rb -d
  rails r tools/ancestry_regiones.rb -d 02-Arthropoda    #para correr solo un conjunto de bases

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def completa
  RegionBio.find_each do |r|
    Rails.logger.debug "#{r.id}-#{r.nombre_region}" if OPTS[:debug]
    r.completa_ancestry
    r.avoid_ancestry = true           # evita la gema ancestry
    r.save
  end
end


start_time = Time.now

if ARGV.any?
  ARGV.each do |base|
    if CONFIG.bases.include?(base)
      Bases.conecta_a base
      Rails.logger.debug "Conectando a: #{base}" if OPTS[:debug]
      completa
    end
  end
else
  CONFIG.bases.each do |base|
    Bases.conecta_a base
    Rails.logger.debug "Conectando a: #{base}" if OPTS[:debug]
    completa
  end
end

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]