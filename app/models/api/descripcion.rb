class Api::Descripcion

  attr_accessor :taxon, :servidor, :timeout, :debug, :locale, :app

  DESCRIPCIONES_ES = %w(conabio_dgcc conabio_tecnico conabio wikipedia_es iucn wikipedia_en)
  DESCRIPCIONES_ES_CIENTIFICO = %w( conabio conabio_tecnico conabio_dgcc  wikipedia_es iucn wikipedia_en  )

  def self.clase_descripcion(descripcion)
    nombre = descripcion.to_s
    permitidas = (DESCRIPCIONES_ES + DESCRIPCIONES_ES_CIENTIFICO).uniq
    raise ArgumentError, "Fuente no permitida" unless permitidas.include?(nombre)
    nombre_clase = nombre == 'iucn' ? 'Iucn' : nombre.camelize
    "Api::#{nombre_clase}".constantize
  end

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
      desc = self.class.clase_descripcion(descripcion)
      resp = desc.new(taxon: taxon, app: app).dame_descripcion
      return { api: descripcion, descripcion: app ? resp.to_s.quita_enlaces : resp } if resp
    end

    nil
  end

  def self.opciones_select
    opciones = []

    eval("DESCRIPCIONES_#{I18n.locale.to_s.gsub('-','_').upcase}").each do |descripcion|
      desc = clase_descripcion(descripcion)
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
    url = "#{servidor}#{uri}"

    parsed_uri = URI::DEFAULT_PARSER.escape(url)

    Rails.logger.debug "[DEBUG] Invocando URL: #{parsed_uri}" if debug

    parsed_uri
  end

end