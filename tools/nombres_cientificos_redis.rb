require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Exporta todas los nombres cientificos a redis:
Se almacenara el .json en db/redis
Es importante borrar los registros de redis si ya existen algunos con los types que se definen.

*** Este script podria correrse con un contrab a cierta hora todos los dias,
a menos que los cambios sean dinamicos en el codigo.

Usage:

  rails r tools/nombres_cientificos_redis.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def system_call(cmd)
  puts "Ejecutando: #{cmd}" if OPTS[:debug]
  system cmd
end

def batches
  puts 'Procesando los nombres cientificos...' if OPTS[:debug]

  Especie.find_each do |taxon|
    puts "#{taxon.id}-#{taxon.nombre_cientifico}" if OPTS[:debug]
    data = taxon.exporta_redis

    File.open("#{@path}/nom_cien_#{I18n.transliterate(taxon.categoria_taxonomica.nombre_categoria_taxonomica).gsub(' ','_')}.json",'a') do |f|
      f.puts(data) if data.present?
    end
  end
end

def load_file
  puts 'Cargando los datos a redis...' if OPTS[:debug]
  CategoriaTaxonomica.all.map{|cat| I18n.transliterate(cat.nombre_categoria_taxonomica).gsub(' ','_')}.uniq.each do |cat|
    f="#{@path}/nom_cien_#{cat}.json"
    system_call("soulmate load cien_#{cat} --redis=redis://#{CONFIG.ip}:6379/0 < #{f}") if File.exists?(f)
  end
end

def delete_files
  puts 'Eliminando archivos anteriores...' if OPTS[:debug]
  CategoriaTaxonomica.all.map{|cat| I18n.transliterate(cat.nombre_categoria_taxonomica).gsub(' ','_')}.uniq.each do |cat|
    f="#{@path}/nom_cien_#{cat}.json"
    File.delete(f) if File.exists?(f)
  end
end

def creando_carpeta
  puts "Creando carpeta \"#{@path}\" si es que no existe..." if OPTS[:debug]
  Dir.mkdir(@path, 0755) if !File.exists?(@path)
end


start_time = Time.now

@path='db/redis'     #cambiar si se desea otra ruta
creando_carpeta
delete_files
batches
load_file

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]