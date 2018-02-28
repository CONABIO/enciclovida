OPTS = Trollop::options do
  banner <<-EOS
Importa a la base los municipios

*** Este script solo es necesario correrlo una vez para generar los municipios

Usage:

  rails r tools/regiones_mapas/municipios.rb

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end


def guarda_municipio(linea)
  datos = linea.gsub("\"", '').split("\t")
  reg = RegionMapa.new
  reg.nombre_region = datos[3]
  reg.geo_id = datos[2]
  reg.tipo_region = 'municipio'

  # Comparo el nombre del estado para asignar su papa
  estado = RegionMapa.where(nombre_region: datos[4])

  if estado.any?
    reg.ancestry = estado.first.path_ids.join('/')
    reg.save
  else
    puts "NO ENCONTRO ESTADO: #{datos[2]}"
  end
end

def lee_archivo
  num_linea = 0

  archivo = 'tools/regiones_mapas/municipios.txt'
  f = File.open(archivo, 'r').read

  f.each_line do |linea|
    num_linea+=1
    next if num_linea == 1
    guarda_municipio(linea)
  end
end


start_time = Time.now

lee_archivo

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]