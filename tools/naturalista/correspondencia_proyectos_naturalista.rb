require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Exporta los datos de los proyectos de NaturaLista de un lista dada.

*** Para sacar los datos de dichos proyectos

Usage:

  rails r tools/correspondencia_proyectos_naturalista.rb -d archivo    #archivo que contiene la lista de los nombres de los proyectos

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def write_file(line)
  Rails.logger.debug "Busqueda: ^#{line}$" if OPTS[:debug]

  response = RestClient.get "http://conabio.inaturalist.org/projects/#{line}.json", :timeout => 1000, :open_timeout => 1000
  @bitacora_no_encontro.puts "#{line},0,0" unless response.present?
  data = JSON.parse(response)
  @bitacora_no_encontro.puts "#{line},1,0" unless data['place_id'].present?

  # Para guardar la informacion en json
  csv = json_to_csv(data)

  @bitacora.puts csv
end

def creando_carpeta(path)
  Rails.logger.debug "Creando carpeta \"#{path}\" si es que no existe..." if OPTS[:debug]
  FileUtils.mkpath(path, :mode => 0755) unless File.exists?(path)
end

def bitacoras(file, no_encontro)
  Rails.logger.debug 'Iniciando bitacoras ...' if OPTS[:debug]
  if !File.exists?(file)
    @bitacora = File.new(file, 'w')
    @bitacora.puts 'id,title,description,url,kml,icon_url,project_observations_count,observed_taxa_count'
  end
  if !File.exists?(no_encontro)
    @bitacora_no_encontro = File.new(no_encontro, 'w')
    @bitacora_no_encontro.puts 'nombre_proyecto,encontro,mapa'
  end
end

def read_file(filename)
  f = File.open(filename, 'r').read

  f.each_line do |line|
    write_file(line.limpia)
  end
  @bitacora.close
  @bitacora_no_encontro.close
end

def json_to_csv(data)
  csv = []
  csv << data['id']
  csv << "\"#{data['title'].limpia_csv}\""
  csv << "\"#{data['description'].limpia_csv}\""
  csv << "http://naturalista.conabio.gob.mx/projects/#{data['slug']}"
  csv << "http://naturalista.conabio.gob.mx/places/geometry/#{data['place_id']}.kml"
  csv << data['project_observations_count']
  csv << data['observed_taxa_count']

  open("#{@ruta_kml}#{data['slug']}.kml", 'wb') do |file|
    file << open("http://naturalista.conabio.gob.mx/places/geometry/#{data['place_id']}.kml").read
  end

  csv.join(',')
end


start_time = Time.now

return unless ARGV.any?
fecha = Time.now.strftime("%Y%m%d%H%M%S")
name = ARGV.first
path = 'tools/correspondencia_proyectos_naturalista'
log_path = 'tools/bitacoras/correspondencia_proyectos_naturalista/'
no_encontro = "#{log_path}#{fecha}_no_encontro_#{name}.csv"
@ruta_kml = 'tools/bitacoras/correspondencia_proyectos_naturalista/'

file = "#{log_path}#{fecha}_#{name}.csv"
Rails.logger.debug "Ruta archivo: #{path}/#{name}" if OPTS[:debug]
Rails.logger.debug "Ruta bitacora: #{file}" if OPTS[:debug]
creando_carpeta log_path
bitacoras file, no_encontro
read_file "#{path}/#{name}"

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]