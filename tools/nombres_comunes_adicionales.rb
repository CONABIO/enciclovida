require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Pone todos los nombres comunes en la tabla adicionales, así es mas sencillo
desplegar que coincidio cuando hace busquedas y reduce el tiempo de carga en la ficha

*** Este script tiene que correrse cada vez que se ingresa una nueva base


Usage:

  rails r tools/nombres_comunes_adicionales.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def completa
  Especie.find_each do |t|
    Rails.logger.debug "#{t.id}-#{t.nombre_cientifico}" if OPTS[:debug]
    hash_nombres_comunes = t.todos_los_nombres_comunes

    if hash_nombres_comunes.any?
      if a = t.adicional
        a.especie_id = t.id
      else
        a = Adicional.new
        a.especie_id = t.id
      end

      a.nombres_comunes = hash_nombres_comunes.to_json

      if a.changed?
        Rails.logger.debug "\t#{a.nombres_comunes}" if OPTS[:debug]
        a.save
      end
    end

  end
end


start_time = Time.now

completa

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]