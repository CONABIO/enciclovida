class Api::Descripcion

  attr_accessor :taxon, :servidor, :timeout, :debug, :locale, :app

  DESCRIPCIONES_ES = %w(conabio wikipedia_es iucn wikipedia_en conabio_tecnico)
  DESCRIPCIONES_ES_CIENTIFICO = %w(conabio_tecnico iucn wikipedia_es wikipedia_en conabio)

  def initialize(opc = {})
    self.taxon = opc[:taxon]
    self.locale = locale || opc[:locale] || I18n.locale || 'es'
    self.app = app || opc[:app] || false
    self.servidor = servidor || opc[:servidor]
    self.timeout = opc[:timeout] || 8
    self.debug = opc[:debug] || Rails.env.development? || false
    Rails.logger.debug "[DEBUG] Inicializar el servicio: #{nombre}" if debug
  end

  def nombre
    "Descripción predeterminada"
  end

  def dame_descripcion
    eval("DESCRIPCIONES_#{locale.to_s.gsub('-','_').upcase}").each do |descripcion|
      desc = eval("Api::#{descripcion.camelize}")
      resp = desc.new(taxon: taxon, app: app).dame_descripcion
      return { api: descripcion, descripcion: app ? resp.to_s.quita_enlaces : resp } if resp
    end

    nil
  end

  def self.opciones_select
    opciones = []

    eval("DESCRIPCIONES_#{I18n.locale.to_s.gsub('-','_').upcase}").each do |descripcion|
      desc = eval("Api::#{descripcion.camelize}")
      opciones << [desc.new.nombre, descripcion]
    end

    opciones
  end

  private

  def solicita(uri)
    request_uri = valida_uri(uri)

    begin
      Timeout::timeout(timeout) do
        Rails.logger.info "Antes de la llamada htttp: #{request_uri}"
        Nokogiri::HTML(URI.open(request_uri), nil, 'UTF-8')
      end
    rescue Timeout::Error
      raise Timeout::Error, "#{nombre} no respondio en los primeros #{timeout} segundos."
    rescue => e
      Rails.logger.info e.inspect
    end
  end

  def valida_uri(uri)
    parsed_uri = URI.encode("#{servidor}#{uri}")

    Rails.logger.debug "[DEBUG] Invocando URL: #{parsed_uri}" if debug
    parsed_uri
  end

end