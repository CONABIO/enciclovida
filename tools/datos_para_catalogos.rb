require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Exporta a un archivo .csv de los datos que no se tienen en los catalogos comparandolos
con NaturaLista

*** Ningun dato aqui presente tiene una fuente formal

Usage:

  rails r tools/datos_para_catalogos.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def datos
  puts 'Procesando los taxones...' if OPTS[:debug]

  Especie.find_each do |taxon|
  #Especie.limit(100).each do |taxon|
    puts "#{taxon.id}\t#{taxon.nombre}" if OPTS[:debug]
    proveedor = taxon.proveedor

    next unless proveedor
    next unless proveedor.naturalista_info.present?

    proveedor.nombres_comunes.each do |datos|
      @bitacora.puts datos
    end
  end
end

def creando_carpeta
  puts "Creando carpeta \"#{@path}\" si es que no existe..." if OPTS[:debug]
  Dir.mkdir(@path, 0755) if !File.exists?(@path)
end

def bitacoras
  puts 'Iniciando bitacoras ...' if OPTS[:debug]
  @bitacora = File.new("#{@path}/#{Time.now.strftime("%Y_%m_%d_%H-%M-%S")}_nombres_comunes.csv", 'w:UTF-8')
  @bitacora.puts 'IdCAT,NombreComun,Lengua,NombreCientifico,NombreCategoriaTaxonomica'
end


start_time = Time.now

@path = 'tools/bitacoras/datos_para_catalogos'
creando_carpeta
bitacoras
datos

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]