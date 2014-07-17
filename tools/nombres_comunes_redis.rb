require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Exporta todas los nombres comunes a redis:
Se almacenara el .json en db/redis/nombres_comunes.json

Usage:

  rails r tools/nombres_comunes_redis.rb

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def system_call(cmd)
  puts "Ejecutando ... #{cmd}" if OPTS[:debug]
  system cmd
end

def batches(file)
  data=''
  NombreComun.find_each do |nombre_comun|
    muchos_nombres = false
    data+= "{\"id\":#{nombre_comun.id},"
    data+= "\"term\":\"#{nombre_comun.nombre_comun}\","
    data+= "\"score\":85,"
    data+= "\"data\":["
    nombre_comun.especies.order('nombre_cientifico ASC').each do |especie|
      data+= ',' if muchos_nombres
      data+= "{\"nombre_cientifico\":\"#{especie.nombre_cientifico}\", \"nombre_categoria_taxonomica\":\"#{especie.categoria_taxonomica.nombre_categoria_taxonomica}\"}"
      muchos_nombres=true
    end
    data+= "]}\n"
  end

  File.open(file,'w') do |f|
    f.puts data
  end
end

start_time = Time.now
file = 'db/redis/nombres_comunes.json'
File.delete(file) if File.exists?(file)
batches(file)
puts "Termino la exportación al archivo: #{file} en #{Time.now - start_time} seg"