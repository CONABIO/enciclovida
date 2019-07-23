require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Exporta a un archivo .csv de los datos que no se tienen en los catalogos comparandolos
con NaturaLista

*** La Fuente de los datos es NaturaLista

Usage:

  rails r tools/datos_para_catalogos.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def datos
  Rails.logger.debug 'Procesando los taxones...' if OPTS[:debug]

  Proveedor.where('naturalista_info IS NOT NULL').find_each do |proveedor|
    #Especie.limit(100).each do |taxon|
    taxon = proveedor.especie
    Rails.logger.debug "#{taxon.id}-#{taxon.nombre_cientifico}" if OPTS[:debug]

    proveedor.nombres_comunes.each do |datos|
      @bitacora.puts datos
    end
  end
end

def creando_carpeta
  Rails.logger.debug "Creando carpeta \"#{@path}\" si es que no existe..." if OPTS[:debug]
  FileUtils.mkpath(@path, :mode => 0755) unless File.exists?(@path)
end

def bitacoras
  Rails.logger.debug 'Iniciando bitacoras ...' if OPTS[:debug]
  @bitacora = File.new("#{@path}/#{Time.now.strftime("%Y_%m_%d_%H-%M-%S")}_nombres_comunes.csv", 'w:UTF-8')
  @bitacora.puts 'IdCAT,NombreComun,Lengua,NombreCientifico,NombreCategoriaTaxonomica,URL'
end


start_time = Time.now

@path = 'tools/bitacoras/datos_para_catalogos'
creando_carpeta
bitacoras
datos

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]