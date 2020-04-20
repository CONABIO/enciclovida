class Api::Descripcion

  attr_accessor :taxon, :servidor, :timeout, :debug

  DESCRIPCIONES = %w(conabio_plinian conabio_xml wikipedia_es wikipedia_en conabio_tecnico)

  def initialize(opc = {})
    self.taxon = opc[:taxon]
    self.servidor = opc[:servidor]
    self.timeout = opc[:timeout] || 8
    self.debug = opc[:debug] || Rails.env.development? || false
    Rails.logger.debug "[DEBUG] Inicializar el servicio: #{nombre}" if debug
  end

  def dame_descripcion
    return if Api::ConabioPlinian.new(taxon: taxon).dame_descripcion
    return if Api::ConabioXml.new(taxon: taxon).dame_descripcion
    return if Api::WikipediaEs.new(taxon: taxon).dame_descripcion
    return if Api::WikipediaEn.new(taxon: taxon).dame_descripcion
    return if Api::ConabioTecnico.new(taxon: taxon).dame_descripcion
  end

  private

  def solicita(uri)
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