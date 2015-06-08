require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Exporta todas los nombres comunes principales que no son de catalogos, a redis:
Se almacenara el .json en db/redis

*** Este script podria correrse cada 15 dias junto con informacion_naturalista.rb
a menos que los cambios sean dinamicos en el codigo.

Usage:

  rails r tools/nombres_principales_redis.rb -d

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

  Adicional.where('nombre_comun_principal IS NOT NULL').find_each do |adicional|
    puts "#{adicional.id}-#{adicional.nombre_comun_principal}" if OPTS[:debug]
    next unless taxon = adicional.especie

    # Guardo en memoria el nombre comun principal original
    nom_com_prin_original = adicional.nombre_comun_principal
    # Veo cual nom_com_prin le corresponde segun catalogos
    adicional.nombre_comun_principal_catalogos

    # Si coincide quiere decir que ese nombre ya esta en redis
    next if adicional.nombre_comun_principal == nom_com_prin_original
    # Asigna de nuevo el valor original
    adicional.nombre_comun_principal = nom_com_prin_original

    json_cien = taxon.exporta_redis
    json_com = adicional.exporta_nom_comun_a_redis

    File.open("#{@path}/nom_cien_prin_#{I18n.transliterate(taxon.categoria_taxonomica.nombre_categoria_taxonomica).gsub(' ','_')}.json",'a') do |f|
      f.puts(json_cien) if json_cien.present?
    end

    File.open("#{@path}/nom_com_prin_#{I18n.transliterate(taxon.categoria_taxonomica.nombre_categoria_taxonomica).gsub(' ','_')}.json",'a') do |f|
      f.puts(json_com) if json_com.present?
    end
  end
end

def load_file
  puts 'Cargando los datos a redis...' if OPTS[:debug]
  CategoriaTaxonomica.all.map{|cat| I18n.transliterate(cat.nombre_categoria_taxonomica).gsub(' ','_')}.uniq.each do |cat|
    f_cien="#{@path}/nom_cien_prin_#{cat}.json"
    f_com="#{@path}/nom_com_prin_#{cat}.json"
    system_call("soulmate add cien_#{cat} --redis=redis://#{IP}:6379/0 < #{f_cien}") if File.exists?(f_cien)
    system_call("soulmate add com_#{cat} --redis=redis://#{IP}:6379/0 < #{f_com}") if File.exists?(f_com)
  end
end

def delete_files
  puts 'Eliminando archivos anteriores...' if OPTS[:debug]
  CategoriaTaxonomica.all.map{|cat| I18n.transliterate(cat.nombre_categoria_taxonomica).gsub(' ','_')}.uniq.each do |cat|
    f_cien="#{@path}/nom_cien_prin_#{cat}.json"
    f_com="#{@path}/nom_com_prin_#{cat}.json"
    File.delete(f_cien) if File.exists?(f_cien)
    File.delete(f_com) if File.exists?(f_com)
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