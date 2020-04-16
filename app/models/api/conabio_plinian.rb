class Api::ConabioPlinian < Api::Descripcion

  def initialize(opc = {})
    super(opc)
    self.servidor = servidor || "http://#{IP}:#{PORT}"
  end

  def nombre
    'CONABIO (plinian core)'
  end

  def dame_descripcion
    return unless cat = taxon.scat
    buscar(cat.catalogo_id)
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
    parsed_uri = URI.parse(URI.encode("#{servidor}#{uri}"))

    Rails.logger.debug "[DEBUG] Invocando URL: #{parsed_uri}" if debug
    parsed_uri
  end

end