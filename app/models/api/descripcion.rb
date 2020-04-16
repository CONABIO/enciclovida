class Api::Descripcion

  attr_accessor :taxon, :servidor, :timeout, :debug

  def initialize(opc = {})
    self.taxon = opc[:taxon]
    self.servidor = opc[:servidor]
    self.timeout = opc[:timeout] || 8
    self.debug = opc[:debug] || Rails.env.development? || false
    Rails.logger.debug "[DEBUG] Inicializar el servicio: #{nombre}" if debug
  end

end