require 'rubygems'

def guarda_redis

  puts 'Procesando especies...'

  errores = 0
  contador = 0

  Especie.where(EstadoRegistro: 1).find_each(batch_size: 1000) do |t|

    begin

      t.guarda_redis(sin_visita: true)

      contador += 1

      puts "#{contador} especies indexadas..." if (contador % 1000).zero?

    rescue => e

      puts "ERROR #{t.id}: #{e.message}"
      puts "=================================="
      puts "ESPECIE: #{t.id}"
      puts "#{e.class}: #{e.message}"
      puts e.backtrace.first(20)
      puts "=================================="

      errores += 1

      File.open("errores_reindex.log", "a") do |f|
        f.puts "#{t.id}|#{t.nombre_cientifico}|#{e.class}|#{e.message}"
        f.puts e.backtrace.first(20)
        f.puts "=================================="
      end

    end

  end

  puts "=================================="
  puts "Especies indexadas: #{contador}"
  puts "Errores totales: #{errores}"
  puts "=================================="

end

start_time = Time.now

guarda_redis

puts "Terminado en #{(Time.now - start_time).round(2)} segundos."