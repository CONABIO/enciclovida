OPTS = Trollop::options do
  banner <<-EOS
Importa a la base las ecoregiones

*** Este script solo es necesario correrlo una vez para generar las ecoregiones

Usage:

  rails r tools/regiones_mapas/ecoregiones.rb

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end


def guarda_ecoregion(linea)
  datos = linea.gsub("\"", '').split("\t")
  reg = RegionMapa.new
  reg.nombre_region = datos[0]
  reg.geo_id = datos[1]
  reg.tipo_region = 'ecoregión'
  reg.ancestry = 1

  reg.save
end

def lee_archivo
  num_linea = 0

  archivo = 'tools/regiones_mapas/ecoregiones.txt'
  f = File.open(archivo, 'r').read
  
  f.each_line do |linea|
    num_linea+=1
    next if num_linea == 1
    guarda_ecoregion(linea)
  end
end

start_time = Time.now

lee_archivo

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]