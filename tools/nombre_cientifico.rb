require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Completa el campo nombre_cientifico .

*** Este script completa el nombre cientifico de acuerdo a la categoria taxonomica.
Correr despues de tener el campo ancestry_ascendente_obligatorio listo

Usage:

  rails r tools/nombre_cientifico.rb -d
  rails r tools/nombre_cientifico.rb -d 02-Arthropoda    #para correr solo un conjunto de bases

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def completa
  EspecieBio.find_each do |taxon|
    Rails.logger.debug "#{taxon.id}-#{taxon.nombre}" if OPTS[:debug]
    taxon.evita_before_save = true
    taxon.pon_nombre_cientifico

    if taxon.nombre_cientifico_changed?
      if taxon.save
        Rails.logger.debug "\t#{taxon.nombre_cientifico}" if OPTS[:debug]
      end
    end
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