require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Exporta todas los nombres comunes a redis:
Se almacenara el .json en db/redis
Es importante borrar los registros de redis si ya existen algunos con los types que se definen.

*** Este script podria correrse con un contrab a cierta hora todos los dias,
a menos que los cambios sean dinamicos en el codigo.

Usage:

  rails r tools/nombres_comunes_redis.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def system_call(cmd)
  puts "Ejecutando: #{cmd}" if OPTS[:debug]
  system cmd
end

def pon_id_falso

end

def batches
  puts 'Procesando los nombres comunes...' if OPTS[:debug]
  NombreComun.find_each do |nombre_comun|
    cont=1

    nombre_comun.especies.order('nombre_cientifico ASC').each do |especie|
      fotos=especie.photos
      foto = fotos.present? ? "<img src='#{fotos.first.thumb_url}' alt='#{especie.nombre_cientifico}' width='50px' \>" :
          "<img src='/assets/app/iconic_taxa/mammalia-75px.png' alt='#{especie.nombre_cientifico}' width='30px' \>"

      data=''
      data+= "{\"id\":#{cont > 1 ? "#{nombre_comun.id}#{cont}" : nombre_comun.id},"   #el ID de nombres_comunes no es unico (uno a muchos)
      data+= "\"term\":\"#{nombre_comun.nombre_comun}\","
      data+= "\"score\":85,"
      data+= "\"data\":{\"nombre_cientifico\":\"#{especie.nombre_cientifico}\", \"foto\":\"#{foto}\", \"autoridad\":\"#{especie.nombre_autoridad}\", \"id\":#{especie.id}}"
      data+= "}\n"

      File.open("#{@path}/nom_com_#{I18n.transliterate(especie.categoria_taxonomica.nombre_categoria_taxonomica)}.json",'a') do |f|
        f.puts data
      end
      cont+=1
    end
  end
end

def load_file
  puts 'Cargando los datos a redis...' if OPTS[:debug]
  CategoriaTaxonomica.all.map{|cat| I18n.transliterate(cat.nombre_categoria_taxonomica)}.uniq.each do |cat|
    f="#{@path}/nom_com_#{cat}.json"
    system_call("soulmate load com_#{cat} --redis=redis://localhost:6379/0 < #{f}") if File.exists?(f)
  end
end

def delete_files
  puts 'Eliminando archivos anteriores...' if OPTS[:debug]
  CategoriaTaxonomica.all.map{|cat| I18n.transliterate(cat.nombre_categoria_taxonomica)}.uniq.each do |cat|
    f="#{@path}/nom_com_#{cat}.json"
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