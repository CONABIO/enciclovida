require 'rubygems'
require 'trollop'
require 'rest_client'
require 'json'

OPTS = Trollop::options do
  banner <<-EOS
Guarda las observaciones de NaturaLista, una vez que ya se asocio el ID

Usage:

  rails r tools/observaciones_naturalista.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def search
  Proveedor.where('naturalista_id IS NOT NULL AND especie_id BETWEEN 8000000 AND 9000000').order(:especie_id).find_each do |proveedor|
    next unless t = proveedor.especie
    Rails.logger.debug "#{t.id}-#{t.nombre_cientifico}" if OPTS[:debug]
    next unless t.especie_o_inferior?
    proveedor.obs_naturalista

    if proveedor.changed?
      if proveedor.save
        Rails.logger.debug "\t\tGuardo la informacion" if OPTS[:debug]
      else
        Rails.logger.debug "\t\tNo pudo guardar la informacion" if OPTS[:debug]
      end
    else
      Rails.logger.debug "\t\tNo hubo cambios" if OPTS[:debug]
    end
  end
end


start_time = Time.now

search

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]
