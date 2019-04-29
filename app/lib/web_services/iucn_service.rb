class IUCNService

  attr_accessor :csv_path

  # Consulta la categoria de riesgo de un taxon dado
  def consultaRiesgo(opts)
    @iucn = CONFIG.iucn.api
    @token = CONFIG.iucn.token

    url = "#{@iucn}/api/v3/species/#{opts[:nombre].limpia_ws}?token=#{@token}"
    url_escape = URI.escape(url)
    uri = URI.parse(url_escape)
    req = Net::HTTP::Get.new(uri.to_s)
    begin
      res = Net::HTTP.start(uri.host, uri.port, :read_timeout => CONFIG.iucn.timeout ) {|http| http.request(req) }
      jres = JSON.parse(res.body)['result']
      jres[0]['category'] if jres.any?
    rescue => e
      nil
    end
  end

  # Guarda en cache la respuesta del servicio
  def dameRiesgo(opc={})
    resp = Rails.cache.fetch("iucn_#{opc[:id]}", expires_in: eval(CONFIG.cache.iucn)) do
      iucn = consultaRiesgo(opc)
      I18n.t("iucn_ws.#{iucn.estandariza}", :default => iucn) if iucn.present?
    end

    resp
  end

  # Accede al archivo que contiene los assessments y la taxonomia dentro de la carpeta versiones_IUCN
  # NOTAS: Este archivo se baja de la pagina de IUCN y hay que unir el archivo de asswessments con el de taxonomy
  def lee_csv(archivo)
    self.csv_path = Rails.root.join('public', 'IUCN', archivo)
    Rails.logger.debug "[DEBUG] - Corriendo con archivo: #{csv_path}"
    return unless File.exists? csv_path

    CSV.foreach(csv_path, :headers => true) do |row|
      puts row.inspect + '-----------'
      return
    end
  end

  # Bitacora especial para catalogos, antes de correr en real, pasarsela
  def bitacora
    log_path = Rails.root.join('log', Time.now.strftime('%Y-%m-%d_%H%m') + '_IUCN.log')
    @@bitacora ||= Logger.new(log_path)
  end

end

