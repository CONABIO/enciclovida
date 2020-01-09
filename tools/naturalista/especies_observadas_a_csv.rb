OPTS = Trollop::options do
  banner <<-EOS
Exporta en un csv los nombres científicos de las especies observadas en naturalista

  rails r tools/naturalista/especies_observadas_a_csv.rb -d place_id taxon_id
  place_id de México: 6793
  taxon_id: cualquier ID de la taxa en naturalista

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def consulta_servicio(params={})
  Rails.logger.debug "Consulta a servicio: #{params.inspect}" if OPTS[:debug]
  # Transforma el hash en array para posteriormente ponerlo en u string como parametro de URL
  params = params.to_a.map{ |p| "#{p[0]}=#{p[1]}" }.join('&')

  begin
    rest_client = RestClient::Request.execute(method: :get, url: "#{CONFIG.inaturalist_api}/observations/species_counts?#{params}", timeout: 20)
    { estatus: true, resultado: JSON.parse(rest_client) }
  rescue => e
    { estatus: false, msg: e }
  end
end

def crea_csv
  params = { 'place_id' => ARGV[0], 'taxon_id' => ARGV[1], 'taxon_is_active' => true, 'per_page' => 1 }

  jresp = consulta_servicio(params)
  exit(0) unless jresp[:estatus]
  taxa = jresp[:resultado]

  totales = taxa['total_results']
  exit(0) unless totales > 0

  archivo = File.open(Rails.root.join('tools','naturalista','log',"especies_observadas_#{Time.now.strftime('%Y%m%d-%H%m%S')}.csv"), "w")
  archivo.puts "ID naturalista,nombre científico,categoría taxonómica"

  paginas = totales%500 > 0 ? (totales/500) + 1 : totales/500

  (paginas).times do |p|
    jresp = consulta_servicio(params.merge('page' => p+1, 'per_page' => 500))
    exit(0) unless jresp[:estatus]

    jresp[:resultado]['results'].each do |resultado|
      archivo.puts "#{resultado['taxon']['id']},#{resultado['taxon']['name']},#{resultado['taxon']['rank']}"
    end
  end

  archivo.close
end

start_time = Time.now

if ARGV.length == 2
  Rails.logger.debug "Con comandos: #{ARGV.inspect}" if OPTS[:debug]
  crea_csv
else
  exit(0)
end

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]
