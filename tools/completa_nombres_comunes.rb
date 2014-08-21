require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Importa los nombres comunes de los taxones a la tabla especies para un manejo facil y rapido

*** Este script podria correrse con un contrab a cierta hora todos los dias,
a menos que los cambios sean dinamicos en el codigo.

Usage:

  rails r tools/completa_nombres_comunes.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def system_call(cmd)
  puts "Ejecutando: #{cmd}" if OPTS[:debug]
  system cmd
end

def batches
  puts 'Procesando los taxones...' if OPTS[:debug]

  Especie.limit(100) do |taxon|
    nombres_comunes = ''

  end
end

def load_file
  puts 'Cargando los datos a redis...' if OPTS[:debug]
  CategoriaTaxonomica.all.map{|cat| I18n.transliterate(cat.nombre_categoria_taxonomica)}.uniq.each do |cat|
    f="#{@path}/nom_cien_#{cat}.json"
    system_call("soulmate load cien_#{cat} --redis=redis://localhost:6379/0 < #{f}") if File.exists?(f)
  end
end

def delete_files
  puts 'Eliminando archivos anteriores...' if OPTS[:debug]
  CategoriaTaxonomica.all.map{|cat| I18n.transliterate(cat.nombre_categoria_taxonomica)}.uniq.each do |cat|
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
puts 'Iniciando la creacion de los archivos json...' if OPTS[:debug]
batches
load_file
puts "Termino la exportación de archivos json en #{Time.now - start_time} seg" if OPTS[:debug]