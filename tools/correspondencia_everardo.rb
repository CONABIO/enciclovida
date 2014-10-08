require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Exporta los ID'S dados los nombres de los taxones.

*** Este script es para llenar la base de Everardo

Usage:

  rails r tools/correspondencia_everardo.rb -d carpeta    #para recibir la capeta de archivos .csv

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
  taxon = Especie.where(:nombre_cientifico => especie == "\"\"" ? genero: "#{genero} #{especie}")
  if taxon && taxon.count == 1
    @bitacora.puts "#{genero},#{especie},#{taxon.first.id}"
  else
    @bitacora_no_encontro.puts "#{genero},#{especie},#{@csv}"
  end
end

def delete_files(path, filename)
  puts 'Eliminando archivos anteriores...' if OPTS[:debug]
  File.delete(filename) if File.exists?(filename)
  File.delete("#{path}no_encontro.csv") if File.exists?("#{path}no_encontro.csv")
end

def creando_carpeta(path)
  puts "Creando carpeta \"#{path}\" si es que no existe..." if OPTS[:debug]
  Dir.mkdir(path, 0755) if !File.exists?(path)
end

def bitacoras(path, filename)
  puts 'Iniciando bitacoras ...' if OPTS[:debug]
  @bitacora = File.new(path+filename, 'w')
  @bitacora.puts 'genero,especie,ID'
  @bitacora_no_encontro = File.new("#{path}no_encontro.csv", 'a+') if !File.exists?(filename)
  @bitacora_no_encontro.puts 'genero,especie,archivo'
end

def read_file(filename)
  f = File.open(filename, 'r').read
  f.each_line do |line|
    write_file(Limpia.cadena(line))
  end
end

start_time = Time.now
puts 'Iniciando la expotacion de .CSV' if OPTS[:debug]
return unless ARGV.any?
name = ARGV.first
path = "tools/#{name}"
log_path = "tools/bitacoras/#{name}/"

Dir["#{path}/*.csv"].map{ |arch| arch.split('/').last }.each do |csv|
  @csv = csv
  puts "Ruta archivo: #{path}/#{csv}" if OPTS[:debug]
  puts "Ruta bitacora: #{log_path}#{csv}" if OPTS[:debug]
  delete_files log_path, csv
  creando_carpeta log_path
  bitacoras log_path, csv
  read_file "#{path}/#{csv}"
end

puts "Termino la exportación de archivos .csv en #{Time.now - start_time} seg" if OPTS[:debug]