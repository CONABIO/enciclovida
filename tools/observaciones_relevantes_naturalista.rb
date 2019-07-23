require 'rubygems'
require 'trollop'
require 'rest_client'
require 'json'

OPTS = Trollop::options do
  banner <<-EOS
Exporta en json las observaciones mas relevantes de acuerdo a los IDS que se metan

Usage:

  rails r tools/observaciones_relevantes_naturalista.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def observaciones
  observaciones_json = []
  observaciones_id = [3353824,3326375,3189075,1093705]#,3351887,2887811,1157949,3209930,2100921,3239543,
                      #1668557,2642697,2856031,274209,2618546,1933212,844238,421602,880355,2109113]

  observaciones_id.each do |id|
    url = "http://naturalista.conabio.gob.mx/observations/#{id}.json"
    Rails.logger.debug "Ruta:  \"#{url}\" ..." if OPTS[:debug]

    begin
      response = RestClient.get "#{url}"
    rescue
      next
    end

    data = JSON.parse(response)

    observacion_hash = {}
    user_hash = {}
    taxon_hash = {}

    observacion_hash[:id] = data['id']
    observacion_hash[:place_guess] = data['place_guess']

    photos = data['observation_photos']
    next unless photos.count > 0
    observacion_hash[:image_url] = photos.first['photo']['large_url']

    user_hash[:login] = data['user']['login']
    user_hash[:name] = data['user']['name']
    user_hash[:user_icon_url] = data['user']['medium_user_icon_url']

    taxon_hash[:default_name] = data['taxon']['common_name']['name'] if data['taxon']['common_name'].present?
    taxon_hash[:name] = data['taxon']['name']

    observacion_hash[:user] = user_hash
    observacion_hash[:taxon] = taxon_hash

    observaciones_json << observacion_hash

  end

  @bitacora.puts "var HOMEPAGE_DATA = {\"observations\":" << observaciones_json.to_json.to_s << '}'
end

def creando_carpeta(path)
  Rails.logger.debug "Creando carpeta \"#{path}\" si es que no existe..." if OPTS[:debug]
  FileUtils.mkpath(path, :mode => 0755) unless File.exists?(path)
end

def bitacora(file)
  Rails.logger.debug 'Iniciando bitacoras ...' if OPTS[:debug]
  if !File.exists?(file)
    @bitacora = File.new(file, 'w')
  end
end


start_time = Time.now

log_path = 'tools/bitacoras/observaciones_relevantes_naturalista'
creando_carpeta(log_path)
bitacora("#{log_path}/#{Time.now.strftime("%Y%m%d%H%M%S")}.js")
observaciones

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]
