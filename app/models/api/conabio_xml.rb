class Api::ConabioXml

  attr_accessor :taxon, :nombre_servicio, :servidor, :timeout, :debug

  def initialize(options = {})
    self.nombre_servicio = 'CONABIO_FICHAS'
    self.servidor = options[:servidor] || "#{IP}:#{PORT}" # después del puerto, termina con '/'
    self.timeout = options[:timeout] || 8
    self.debug = options[:debug] || false
    Rails.logger.debug "[DEBUG] Inicializar el servicio: #{nombre}"
  end
  
  def nombre
    'CONABIO (XML)'
  end

  def dame_descripcion
    if cat = taxon.scat
      desc = buscar(cat.catalogo_id)

      if desc.blank?
        #TaxonDescribers::ConabioViejo.describe(taxon)
      else
        desc
      end

    else  # Consulta en las fichas viejas
      #TaxonDescribers::ConabioViejo.describe(taxon)
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

    Rails.logger.debug "[DEBUG] Invocando URL: #{parsed_uri}"
    parsed_uri
  end

end