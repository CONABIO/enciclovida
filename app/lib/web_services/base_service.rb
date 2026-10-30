require "net/http"
require "json"
require "uri"

module WebServices
  class BaseService
    class RequestError < StandardError
      attr_reader :status

      def initialize(message, status: nil)
        @status = status
        super(message)
      end
    end

    DEFAULT_OPEN_TIMEOUT = 10
    DEFAULT_READ_TIMEOUT = 30

    private

    def get_json(url, headers: {})
      uri = URI.parse(url)

      unless uri.is_a?(URI::HTTPS)
        raise RequestError, "La URL debe utilizar HTTPS"
      end

      request = Net::HTTP::Get.new(uri)

      headers.each do |key, value|
        request[key] = value
      end

      response = Net::HTTP.start(
        uri.host,
        uri.port,
        use_ssl: true,
        open_timeout: DEFAULT_OPEN_TIMEOUT,
        read_timeout: DEFAULT_READ_TIMEOUT
      ) do |http|
        http.request(request)
      end

      unless response.is_a?(Net::HTTPSuccess)
        raise RequestError.new( "El servicio respondió HTTP #{response.code}", status: response.code.to_i )
      end
      JSON.parse(response.body)
    rescue JSON::ParserError => e
      raise RequestError, "El servicio devolvió JSON inválido: #{e.message}"

    rescue Net::OpenTimeout, Net::ReadTimeout, SocketError, SystemCallError, OpenSSL::SSL::SSLError => e
      raise RequestError, "Error de conexión: #{e.class}"
    end
  end
end