require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Importa la foto principal de los taxones a la tabla especies para un manejo facil y rapido

*** Este script es para poner el la primera foto (si tiene) en la tabla de especies

Usage:

  rails r tools/foto_principal.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def foto_principal
  Especie.find_each do |taxon|
    Rails.logger.debug "#{taxon.id}-#{taxon.nombre_cientifico}" if OPTS[:debug]
    adicional = taxon.asigna_foto

    if adicional[:cambio]
      Rails.logger.debug "CAMBIO: \t#{adicional[:adicional].foto_principal}"
      adicional[:adicional].save
    end
  end
end


start_time = Time.now

foto_principal

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]