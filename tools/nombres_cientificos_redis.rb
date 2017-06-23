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

def sistema(cmd)
  puts "Ejecutando: #{cmd}" if OPTS[:debug]
  system cmd
end

def procesando_nombres
  puts 'Procesando los nombres cientificos...' if OPTS[:debug]

  #Especie.find_each do |t|
  Especie.limit(100).each do |t|
    puts "#{t.id}-#{t.nombre_cientifico}" if OPTS[:debug]

    # Sacando el conteo de fotos al vuelo
    t.fotos_totales_principal
    data = t.redis(foto_principal: t.x_foto_principal, fotos_totales: t.x_fotos_totales).to_json.to_s

    # Para guardar la foto principal
    if a = t.adicional
      a.foto_principal = t.x_best_photo
      a.save if a.changed?
    else
      t.adicional = Adicional.create({foto_principal: t.x_best_photo, especie_id: t.id})
    end

    File.open("#{@path}/nom_cien_#{I18n.transliterate(t.categoria_taxonomica.nombre_categoria_taxonomica).gsub(' ','_')}.json",'a') do |f|
      f.puts(data)
    end
  end
end

def cargando_archivos
  puts 'Cargando los datos a redis...' if OPTS[:debug]
  CategoriaTaxonomica.all.map{|cat| I18n.transliterate(cat.nombre_categoria_taxonomica).gsub(' ','_')}.uniq.each do |cat|
    f="#{@path}/nom_cien_#{cat}.json"
    sistema("soulmate load cien_#{cat} --redis=redis://#{IP}:6379/0 < #{f}") if File.exists?(f)
  end
end

def borrando_archivos
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
borrando_archivos
procesando_nombres
#cargando_archivos

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]