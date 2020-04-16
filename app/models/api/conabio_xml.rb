class Api::ConabioXml < Api::Descripcion

  attr_accessor :wsdl, :key

  def initialize(opc = {})
    super(opc)
    self.servidor = servidor || 'http://conabioweb.conabio.gob.mx'
    self.wsdl = opc[:wsdl] || "#{servidor}/webservice/conabio_varias_fichas.wsdl"
    self.key = opc[:key] || 'La completa armonia de una obra imaginativa con frecuencia es la causa que los irreflexivos la supervaloren.'
  end

  def nombre
    'CONABIO (XML)'
  end

  def dame_descripcion
    buscar(taxon.nombre_cientifico.limpiar.limpia)
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