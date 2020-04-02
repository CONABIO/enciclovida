class Api::ConabioPlinian

  attr_accessor :nombre_servicio, :servidor, :timeout, :debug, :taxon

  def self.nombre
    'CONABIO (plinian core)'
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


  #private

  #def conabio_service
  #  @conabio_service=New_Conabio_Service.new(:timeout => 20)
  #end


  def initialize(options = {})
    self.nombre_servicio = 'CONABIO_FICHAS'
    self.servidor = options[:servidor] || "#{IP}:#{PORT}" # después del puerto, termina con '/'
    self.timeout = options[:timeout] || 8
    self.debug = options[:debug] || false
    Rails.logger.debug "[DEBUG] Inicializar el servicio: #{@service_name}"
  end

  def buscar(q)
    Rails.logger.debug "[DEBUG] Se realizará la busqueda de: #{q}"
    # Llamar a 'infoEspecie', quien nos devolverá código html con la infomración de la especie
    # Por prueba, se envia el taxón 1, pero q, se envía el que se va a buscar realmente

    if Fichas::Taxon.where(IdCAT: q).first
      request("fichas/front/#{q}")
    else
      nil
    end
  end

  def request(method, *args)
    request_uri = get_uri(method, *args)
    Rails.logger.debug "Los argumentos son: #{args}"

    begin
      timed_out = Timeout::timeout(@timeout) do
        Nokogiri::HTML(open(request_uri), nil, 'UTF-8')
      end
    rescue Timeout::Error
      raise Timeout::Error, "#{@service_name} didn't respond within #{@timeout} seconds."
    end
  end

  def get_uri(method, *args)
    arg = args.first unless args.first.is_a?(Hash)
    uri = "http://#{@server}#{method}"

    Rails.logger.debug "[DEBUG] Invocando URL con los datos: " + uri
    URI.parse(URI.encode(uri))
  end

end