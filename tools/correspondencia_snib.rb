require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Exporta los ID'S dados los nombres de los taxones de la base de everardo.

*** Se corre cada determinado timpo por si los taxones cambiaron
*** Crear la carpeta tools/correspondencia_snib/ y dentro poner la carpeta con los .csv a correr

Usage:

  rails r tools/correspondencia_snib.rb -d carpeta    #para recibir la capeta de archivos .csv

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def system_call(cmd)
  puts "Ejecutando: #{cmd}" if OPTS[:debug]
  system cmd
end

def write_file(line)
  return if line == 'genero,especie'    #quito la cabecera
  l = line.split(',')
  genero = l.first
  especie = l.last
  puts "Busqueda: #{genero} #{especie}$" if OPTS[:debug]
                                        #hace la comparacion por si es vacio especie
  taxon = Especie.where(:nombre_cientifico => especie == "\"\"" ? genero: "#{genero} #{especie}")
  if taxon.first && taxon.count == 1
    @bitacora.puts "#{genero},#{especie},#{taxon.first.id}"
  else
    @bitacora_no_encontro.puts "#{genero},#{especie},#{@csv}"
  end
end

def creando_carpeta(path)
  puts "Creando carpeta \"#{path}\" si es que no existe..." if OPTS[:debug]
  Dir.mkdir(path, 0755) if !File.exists?(path)
end

def bitacoras(file, no_encontro)
  puts 'Iniciando bitacoras ...' if OPTS[:debug]
  if !File.exists?(file)
    @bitacora = File.new(file, 'w')
    @bitacora.puts 'genero,especie,ID'
  end
  if !File.exists?(no_encontro)
    @bitacora_no_encontro = File.new(no_encontro, 'w')
    @bitacora_no_encontro.puts 'genero,especie,archivo'
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
@no_encontro = "#{log_path}no_encontro.csv"

Dir["#{path}/*.csv"].map{ |arch| arch.split('/').last }.each do |csv|
  @csv = csv
  @file = log_path + csv
  puts "Ruta archivo: #{path}/#{csv}" if OPTS[:debug]
  puts "Ruta bitacora: #{@file}" if OPTS[:debug]
  creando_carpeta log_path
  bitacoras @file, @no_encontro
  read_file "#{path}/#{csv}"
end

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]