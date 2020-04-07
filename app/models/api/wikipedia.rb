class Api::Wikipedia

  attr_accessor :taxon, :nombre_servicio, :servidor, :timeout, :debug, :wsdl, :key

  def initialize(opc = {})
    self.servidor = opc[:servidor] || "http://en.wikipedia.org"
    self.timeout = opc[:timeout] || 8
    self.debug = opc[:debug] || Rails.env.development? || false
    Rails.logger.debug "[DEBUG] Inicializar el servicio: #{nombre}" if debug
  end

  def nombre
    'Wikipedia (Inglés)'
  end

  def dame_descripcion
    buscar(taxon.nombre_cientifico.limpiar.limpia)
  end

  def summary(title)
    begin
      response = parse(:page => title, :redirects => true)

      hxml = Nokogiri::HTML(HTMLEntities.new.decode(response.at( "text" ).try( :inner_text )))
      hxml.search('table').remove
      hxml.search("//comment()").remove
      summary = ( hxml.search("//p").detect{|node| !node.inner_html.strip.blank?} || hxml ).inner_html.to_s.strip
      summary = summary.sanitize(tags: %w(p i em b strong))
      summary.gsub! /\[.*?\]/, ''
      summary

    rescue Timeout::Error => e
      Rails.logger.info "[INFO] Wikipedia API call failed while setting taxon summary: #{e.message}"
      return
    end
  end

  private

  def buscar(q)
    begin
      Rails.logger.debug "[DEBUG] Invocando URL: #{wsdl}" if debug
      client = Savon.client(wsdl: wsdl)

      begin
        Timeout::timeout(timeout) do
          response = client.call(:data_taxon, message: { scientific_name: URI.encode(q.gsub(' ', '_')), key: key })

          response.body[:data_taxon_response][:return].encode('iso-8859-1').force_encoding('UTF-8').gsub(/\n/,'<br>') if
              response.body[:data_taxon_response][:return].present?
        end
      rescue Timeout::Error, Errno::ECONNRESET
        raise Timeout::Error, "#{nombre} no respondio en los primeros #{timeout} segundos."
      end

    rescue Savon::SOAPFault => e
      Rails.logger.debug e.message if debug
    end
  end

end