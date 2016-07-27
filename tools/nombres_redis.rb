require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Exporta todos los nombres (comunes y cientificos):
Se almacenara el .json en db/redis
Es importante borrar los registros de redis si ya existen algunos con los types que se definen.

*** Este script podria correrse con un contrab a cierta hora todos los dias,
a menos que los cambios sean dinamicos en el codigo.

Usage:

  rails r tools/nombres_redis.rb -d

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
  #Especie.limit(100).each do |taxon|
    puts "#{taxon.id}-#{taxon.nombre_cientifico}" if OPTS[:debug]
    data = taxon.exporta_redis

    File.open("#{@path}/nom_cien_#{I18n.transliterate(taxon.categoria_taxonomica.nombre_categoria_taxonomica).gsub(' ','_')}.json",'a') do |f|
      f.puts(data)
    end
  end

  puts 'Procesando los nombres comunes...' if OPTS[:debug]

  NombreComun.find_each do |nombre_comun|
    #NombreComun.limit(100).each do |nombre_comun|
    puts "#{nombre_comun.id}-#{nombre_comun.nombre_comun}" if OPTS[:debug]

    nombre_comun.especies.distinct.each do |taxon|
      data = nombre_comun.exporta_redis(taxon)

      File.open("#{@path}/nom_com_#{I18n.transliterate(taxon.categoria_taxonomica.nombre_categoria_taxonomica).gsub(' ','_')}.json",'a') do |f|
        f.puts(data) if data.present?
      end
    end
  end

  puts 'Procesando los nombres cientificos...' if OPTS[:debug]

  Adicional.where('nombre_comun_principal IS NOT NULL').find_each do |adicional|
    #Adicional.where('nombre_comun_principal IS NOT NULL').limit(100).each do |adicional|
    next unless taxon = adicional.especie
    puts "#{taxon.id}-#{taxon.nombre_cientifico}-#{adicional.id}-#{adicional.nombre_comun_principal}" if OPTS[:debug]

    # Los nombres comunes de catalogos, los comparamos para no repetir
    nombres_comunes = taxon.nombres_comunes.map{|nc| I18n.transliterate(nc.nombre_comun.downcase)}
    if nombres_comunes.any?
      next if nombres_comunes.include?(I18n.transliterate(adicional.nombre_comun_principal.downcase))
    end

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
  puts 'Cargando los nombres cientificos a redis...' if OPTS[:debug]

  CategoriaTaxonomica.all.map{|cat| I18n.transliterate(cat.nombre_categoria_taxonomica).gsub(' ','_')}.uniq.each do |cat|
    f="#{@path}/nom_cien_#{cat}.json"
    system_call("soulmate load #{cat} --redis=redis://#{IP}:6379/0 < #{f}") if File.exists?(f)
  end

  puts 'Cargando los nombres comunes a redis...' if OPTS[:debug]

  CategoriaTaxonomica.all.map{|cat| I18n.transliterate(cat.nombre_categoria_taxonomica).gsub(' ','_')}.uniq.each do |cat|
    f="#{@path}/nom_com_#{cat}.json"
    system_call("soulmate add #{cat} --redis=redis://#{IP}:6379/0 < #{f}") if File.exists?(f)
  end

  puts 'Cargando los nombres principales a redis...' if OPTS[:debug]

  CategoriaTaxonomica.all.map{|cat| I18n.transliterate(cat.nombre_categoria_taxonomica).gsub(' ','_')}.uniq.each do |cat|
    f_cien="#{@path}/nom_cien_prin_#{cat}.json"
    f_com="#{@path}/nom_com_prin_#{cat}.json"
    system_call("soulmate add #{cat} --redis=redis://#{IP}:6379/0 < #{f_cien}") if File.exists?(f_cien)
    system_call("soulmate add #{cat} --redis=redis://#{IP}:6379/0 < #{f_com}") if File.exists?(f_com)
  end
end

def delete_files
  puts 'Eliminando archivos anteriores...' if OPTS[:debug]

  CategoriaTaxonomica.all.map{|cat| I18n.transliterate(cat.nombre_categoria_taxonomica).gsub(' ','_')}.uniq.each do |cat|
    f="#{@path}/nom_cien_#{cat}.json"
    File.delete(f) if File.exists?(f)

    f="#{@path}/nom_com_#{cat}.json"
    File.delete(f) if File.exists?(f)

    f="#{@path}/nom_cien_prin_#{cat}.json"
    File.delete(f) if File.exists?(f)

    f="#{@path}/nom_com_prin_#{cat}.json"
    File.delete(f) if File.exists?(f)
  end
end

def creando_carpeta
  puts "Creando carpeta \"#{@path}\" si es que no existe..." if OPTS[:debug]
  Dir.mkdir(@path, 0755) if !File.exists?(@path)
end


start_time = Time.now

@path='db/redis'     #cambiar si se desea otra ruta
#creando_carpeta
#delete_files
#batches
load_file

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]