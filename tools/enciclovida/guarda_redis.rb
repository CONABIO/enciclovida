require 'rubygems'
require 'optimist'

OPTS = Optimist::options do
  banner <<-EOS
Exporta todas los nombres cientificos, nombres comunes de catalogos y nombres comunes de naturalista a redis,
adicionalmente guarda la foto principal y el nombre comun principal

*** Este script solo es necesario correrlo una vez, ya que la ficha actualiza el taxon

Usage:

  rails r tools/guarda_redis.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end


def guarda_redis

  Rails.logger.debug 'Procesando los nombres cientificos...' if OPTS[:debug]
  ultima_corrida = false
  errores = 0

  Especie.where(EstadoRegistro: 1).find_each(batch_size: 1000) do |t|
    begin
      t.guarda_redis(sin_visita: true)
    rescue => e
      errores += 1

      File.open("errores_reindex.log", "a") do |f|
        f.puts "#{t.id}|#{t.nombre_cientifico}|#{e.class}|#{e.message}"
      end

      puts "ERROR #{t.id}"
    end
  end

  puts "Errores totales: #{errores}"
end
start_time = Time.now
guarda_redis
Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]
