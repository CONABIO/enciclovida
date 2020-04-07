class Api::ConabioPlinian

  attr_accessor :taxon, :nombre_servicio, :servidor, :timeout, :debug

  def initialize(opc = {})
    self.servidor = opc[:servidor] || "#{IP}:#{PORT}" # después del puerto, termina con '/'
    self.timeout = opc[:timeout] || 8
    self.debug = opc[:debug] || Rails.env.development? || false
    Rails.logger.debug "[DEBUG] Inicializar el servicio: #{nombre}" if debug
  end

  def nombre
    'CONABIO (plinian core)'
  end

  def dame_descripcion
    if cat = taxon.scat
      buscar(cat.catalogo_id)
    end
  end


  private

  def buscar(q)
    if Fichas::Taxon.where(IdCAT: q).first
      request("fichas/front/#{q}")
    else
      nil
    end
  end

  def request(uri)
    request_uri = valida_uri(uri)

    begin
      Timeout::timeout(timeout) do
        Nokogiri::HTML(open(request_uri), nil, 'UTF-8')
      end
    rescue Timeout::Error
      raise Timeout::Error, "#{nombre} no respondio en los primeros #{timeout} segundos."
    end
  end

  def valida_uri(uri)
    parsed_uri = URI.parse(URI.encode("http://#{servidor}#{uri}"))

    Rails.logger.debug "[DEBUG] Invocando URL: #{parsed_uri}" if debug
    parsed_uri
  end

end