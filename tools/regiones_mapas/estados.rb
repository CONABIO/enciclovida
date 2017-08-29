OPTS = Trollop::options do
  banner <<-EOS
Importa a la base los estados

*** Este script solo es necesario correrlo una vez para generar los estados

Usage:

  rails r tools/regiones_mapas/estados.rb

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end


def guarda_estado(linea)
  datos = linea.gsub("\"", '').split("\t")
  reg = RegionMapa.new
  reg.nombre_region = datos[0]
  reg.geo_id = datos[1]
  reg.tipo_region = 'estado'
  reg.ancestry = 1

  reg.save
end

def lee_archivo
  crea_root_inicial
  num_linea = 0

  archivo = 'tools/regiones_mapas/estados.txt'
  f = File.open(archivo, 'r').read

  f.each_line do |linea|
    num_linea+=1
    next if num_linea == 1
    guarda_estado(linea)
  end
end

def crea_root_inicial
  reg = RegionMapa.new
  reg.nombre_region = 'México'
  reg.tipo_region = 'país'
  reg.save
end

start_time = Time.now

lee_archivo

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]