require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Exporta los ID'S dados los nombres de los taxones de la base de everardo.

*** Se corre cada determinado timpo por si los taxones cambiaron, es conveniente borrar los campos snib_id y snib_reino antes de meter nuevos
*** Crear la carpeta tools/correspondencia_snib/ y dentro poner la carpeta con unicamente los .csv a correr,
    cada linea debe tener: [genero, especie, spid] y el archivo se debe tener el nombre del reino correspondiente.

Usage:

  rails r tools/correspondencia_snib.rb -d carpeta    #para recibir la capeta de archivos .csv

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def write_file(line)
  return if line.include? 'genero,especie'    #quito la cabecera
  l = line.split(',')
  genero = l[0]
  especie = l[1]
  spid = l[2]
  reino = @filename.downcase

  Rails.logger.debug "Busqueda: ^#{genero} #{especie}$" if OPTS[:debug]
  #hace la comparacion por si es vacio especie
  taxon = Especie.where("nombre_cientifico LIKE '#{genero} % #{especie}' OR nombre_cientifico='#{genero} #{especie}'")

  if taxon.first && taxon.count == 1
    Rails.logger.debug "\tEncontro" if OPTS[:debug]
    if proveedor = taxon.first.proveedor
      proveedor.snib_id = spid
      proveedor.snib_reino = reino
    else
      proveedor = Proveedor.new(:especie_id => taxon.first.id, :snib_id => spid, :snib_reino => reino)
    end

    if proveedor.changed?
      Rails.logger.debug "\tEncontro cambios"
      @bitacora.puts "#{genero},#{especie},#{spid},#{taxon.first.id}" if proveedor.save
    end

  elsif taxon.count > 1
    Rails.logger.debug "\tEncontro más de uno" if OPTS[:debug]
    existia_especie = false;

    taxon.each do |t|
      categoria = t.categoria_taxonomica.nombre_categoria_taxonomica.downcase

      if categoria == 'especie'
        if proveedor = t.proveedor
          proveedor.snib_id = spid
          proveedor.snib_reino = reino
        else
          proveedor = Proveedor.new(:especie_id => t.id, :snib_id => spid, :snib_reino => reino)
        end

        if proveedor.changed?
          Rails.logger.debug "\tEncontro cambios"
          @bitacora.puts "#{genero},#{especie},#{spid},#{t.id}" if proveedor.save
        end

        existia_especie = true;
        break
      end
    end

    if !existia_especie
      Rails.logger.debug "\t\tNinguno coincidio" if OPTS[:debug]
      @bitacora_no_encontro.puts "#{genero},#{especie},#{@filename},Revisar"
    end

  else
    Rails.logger.debug "\tNO encontro" if OPTS[:debug]
    @bitacora_no_encontro.puts "#{genero},#{especie},#{@filename}"
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
    @bitacora.puts 'genero,especie,spid,rid'
  end
  if !File.exists?(no_encontro)
    @bitacora_no_encontro = File.new(no_encontro, 'w')
    @bitacora_no_encontro.puts 'genero,especie,spid,archivo'
  end
end

def read_file(filename)
  f = File.open(filename, 'r').read
  f.each_line do |line|
    write_file(Limpia.cadena(line))
  end
  @bitacora.close
  @bitacora = nil
end


start_time = Time.now

return unless ARGV.any?
name = ARGV.first
path = "tools/correspondencia_snib/#{name}"
log_path = "tools/bitacoras/correspondencia_snib/#{Time.now.strftime("%Y%m%d%H%M%S")}-#{name}/"
no_encontro = "#{log_path}no_encontro.csv"

Dir["#{path}/*"].map{ |arch| arch.split('/').last }.each do |f|
  @filename = f
  @file = log_path + f
  Rails.logger.debug "Ruta archivo: #{path}/#{f}" if OPTS[:debug]
  Rails.logger.debug "Ruta bitacora: #{@file}" if OPTS[:debug]
  creando_carpeta log_path
  bitacoras @file, no_encontro
  read_file "#{path}/#{f}"
end

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]