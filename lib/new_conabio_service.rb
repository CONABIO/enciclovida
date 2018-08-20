
require 'timeout'
require 'uri'

class New_Conabio_Service

  def initialize(options = {})
    @service_name = 'CONABIO_FICHAS'
    @server = options[:server] || 'localhost:3000'
    @timeout = options[:timeout] || 8
    @debug = options[:debug] || false
    Rails.logger.debug "[DEBUG] Inicializar el servicio: #{@service_name}"
  end

  def search(q)
    Rails.logger.debug "[DEBUG] Se realizará la busqueda de: #{q}"
    # Llamar a 'infoEspecie', quien nos devolverá código html con la infomración de la especie

    #@resultado = "o&Atilde;&sup3;n"
    #@resultado.encode('iso-8859-1')

    # Por prueba, se envia el taxón 1, pero q, se envía el que se va a buscar realmente
    request('infoEspecie/1', q)
  end

  def request(method, *args)
    request_uri = get_uri(method, *args)
    puts("Los argumentos son: #{args}")
    begin
      timed_out = Timeout::timeout(@timeout) do
        Rails.logger.debug "[DEBUG] #{self.class.name} getting #{request_uri}"
        Nokogiri::HTML(open(request_uri))
        #@timeout.encode('iso-8859-1').force_encoding('UTF-8')
      end
      #timed_out.encoding
      #Rails.logger.debug "[DEBUG] Resultado: #{timed_out}"
    rescue Timeout::Error
      raise Timeout::Error, "#{@service_name} didn't respond within #{@timeout} seconds."
    end
  end

  def get_uri(method, *args)
    arg = args.first unless args.first.is_a?(Hash)
    uri = "http://#{@server}/#{method}"
    #uri += "/#{arg}" if arg

    Rails.logger.debug "[DEBUG] Invocando URL con los datos: " + uri
    URI.parse(URI.encode(uri))
  end

end

