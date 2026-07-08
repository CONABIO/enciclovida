require 'rubygems'

def exporta_a_blurrilly
  puts 'Exportando nombres científicos...'

  client_cientifico = Blurrily::Client.new(
    host: ENV.fetch('BLURRILY_HOST', '127.0.0.1'),
    db_name: 'nombres_cientificos'
  )

  client_comun = Blurrily::Client.new(
    host: ENV.fetch('BLURRILY_HOST', '127.0.0.1'),
    db_name: 'nombres_comunes'
  )

  contador = 0

  Especie.find_each do |taxon|
    client_cientifico.put(taxon.nombre_cientifico, taxon.id)

    contador += 1
    puts "#{contador} especies indexadas..." if (contador % 1000).zero?
  end

  puts 'Exportando nombres comunes...'

  contador = 0

  NombreComun.find_each do |nom|
    client_comun.put(nom.nombre_comun, nom.id)

    contador += 1
    puts "#{contador} nombres comunes indexados..." if (contador % 1000).zero?
  end
end

def creando_carpeta
  puts "Creando carpeta \"#{@path}\" si no existe..."
  Dir.mkdir(@path, 0755) unless File.exist?(@path)
end

def delete_files
  puts 'Eliminando índices anteriores...'

  f_cien = "#{@path}/nombres_cientificos.trigrams"
  f_com = "#{@path}/nombres_comunes.trigrams"

  File.delete(f_cien) if File.exist?(f_cien)
  File.delete(f_com) if File.exist?(f_com)
end

start_time = Time.now

@path = 'db/blurrily'

creando_carpeta
delete_files
exporta_a_blurrilly

puts "Terminado en #{(Time.now - start_time).round(2)} segundos."