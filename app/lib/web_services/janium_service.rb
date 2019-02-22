
require 'timeout'
require 'uri'

class Janium_Service

  def initialize(options = {})
    @service_name = 'Bioteca CONABIO'
    @server = options[:server] || "#{IP}:#{PORT}" # después del puerto, termina con '/'
    @timeout = options[:timeout] || 8
    @debug = options[:debug] || false
    Rails.logger.debug "[DEBUG] Inicializar el servicio: #{@service_name}"
  end

  def search(taxon_name)
    Rails.logger.debug "[DEBUG] Se realizará la busqueda de: #{taxon_name}"
    request("registros_bioteca/#{taxon_name}")
  end

  def request(method, *args)
    request_uri = get_uri(method, *args)
    Rails.logger.debug "Los argumentos son: #{args}"

    begin
      timed_out = Timeout::timeout(@timeout) do
        Nokogiri::HTML(open(request_uri), nil, 'UTF-8')
      end
    rescue Timeout::Error
      raise Timeout::Error, "#{@service_name} didn't respond within #{@timeout} seconds."
    end
  end

  def get_uri(method, *args)
    arg = args.first unless args.first.is_a?(Hash)
    uri = "http://#{@server}#{method}"

    Rails.logger.debug "[DEBUG] Invocando URL con los datos: " + uri
    URI.parse(URI.encode(uri))
  end
end