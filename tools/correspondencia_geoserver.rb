require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Exporta los datos del geoserver para la distribucion.

*** Se corre cada determinado timpo por si los taxones cambiaron
*** Crear la carpeta tools/correspondencia_geoserver/ y dentro poner la carpeta con unicamente los .csv a correr

Usage:

  rails r tools/correspondencia_geoserver.rb -d carpeta    #para recibir la capeta de archivos .csv

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def write_file(line)
  return if line.include? 'reino,division,clase,orden,familia,gen,sp,sub_sp,mapa,styler,boubox'    #quito la cabecera
  l = line.split(',')
  genero = l[5]
  especie = l[6]
  subespecie = l[7]
  layers = l[8]
  styles = l[9]
  bbox = l[10]

  Rails.logger.debug "Busqueda: ^#{genero} #{especie} #{subespecie}$" if OPTS[:debug]
  # Para guardar la informacion en json
  info = info_a_json(layers, styles, bbox)

  #hace la comparacion por si es vacio subespecie
  taxon = Especie.where(:nombre_cientifico => subespecie.present? ? "#{genero} #{especie} #{subespecie}" : "#{genero} #{especie}")

  if taxon.first && taxon.count == 1
    Rails.logger.debug "\tEncontro" if OPTS[:debug]
    if proveedor = taxon.first.proveedor
      proveedor.geoserver_info = info
    else
      proveedor = Proveedor.new(:especie_id => taxon.first.id, :geoserver_info => info)
    end

    if proveedor.changed?
      @bitacora.Rails.logger.debug "#{genero},#{especie},#{subespecie},#{layers},#{taxon.first.id}" if proveedor.save
    end
  else
    Rails.logger.debug "\tNO encontro" if OPTS[:debug]
    @bitacora_no_encontro.puts "#{genero},#{especie},#{subespecie}#{layers}"
  end
end

def creando_carpeta(path)
  Rails.logger.debug "Creando carpeta \"#{path}\" si es que no existe..." if OPTS[:debug]
  FileUtils.mkpath(path, :mode => 0755) unless File.exists?(path)
end

def bitacoras(file, no_encontro)
  Rails.logger.debug 'Iniciando bitacoras ...' if OPTS[:debug]
  if !File.exists?(file)
    @bitacora = File.new(file, 'w')
    @bitacora.puts 'genero,especie,subespecie,layers,id'
  end
  if !File.exists?(no_encontro)
    @bitacora_no_encontro = File.new(no_encontro, 'w')
    @bitacora_no_encontro.puts 'genero,especie,subespecie,layers'
  end
end

def read_file(filename)
  @filename = filename.split('/')[3]
  f = File.open(filename, 'r').read
  f.each_line do |line|
    write_file(Limpia.cadena(line))
  end
  @bitacora.close
  @bitacora = nil
end

def info_a_json(layers, styles, bbox)
  info = Hash.new
  info[:layers] = layers
  info[:styles] = styles

  # Ordenamos las coordenadas para el bbox
  bx = bbox.split(' ')
  info[:bbox] = "#{bx[1][5..-1]},#{bx[0][5..-1]},#{bx[3][5..-1]},#{bx[2][5..-1]}"

  info.to_json
end


start_time = Time.now

return unless ARGV.any?
name = ARGV.first
path = "tools/correspondencia_geoserver/#{name}"
log_path = "tools/bitacoras/correspondencia_geoserver/#{Time.now.strftime("%Y%m%d%H%M%S")}-#{name}/"
no_encontro = "#{log_path}no_encontro.csv"

Dir["#{path}/*.csv"].map{ |arch| arch.split('/').last }.each do |csv|
  @csv = csv
  @file = log_path + csv
  Rails.logger.debug "Ruta archivo: #{path}/#{csv}" if OPTS[:debug]
  Rails.logger.debug "Ruta bitacora: #{@file}" if OPTS[:debug]
  creando_carpeta log_path
  bitacoras @file, no_encontro
  read_file "#{path}/#{csv}"
end

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]