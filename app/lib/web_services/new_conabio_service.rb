
require 'timeout'
require 'uri'

class New_Conabio_Service

  def initialize(options = {})
    @service_name = 'CONABIO_FICHAS'
    @server = options[:server] || "#{IP}:#{PORT}" # después del puerto, termina con '/'
    @timeout = options[:timeout] || 8
    @debug = options[:debug] || false
    Rails.logger.debug "[DEBUG] Inicializar el servicio: #{@service_name}"
  end

  def search(q)
    Rails.logger.debug "[DEBUG] Se realizará la busqueda de: #{q}"
    # Llamar a 'infoEspecie', quien nos devolverá código html con la infomración de la especie
    # Por prueba, se envia el taxón 1, pero q, se envía el que se va a buscar realmente
    request("infoEspecie/#{q}")
  end

  def request(method, *args)
    request_uri = get_uri(method, *args)
    puts("Los argumentos son: #{args}")
    begin
      timed_out = Timeout::timeout(@timeout) do
        Rails.logger.debug "[DEBUG] #{self.class.name} getting #{request_uri}"
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

