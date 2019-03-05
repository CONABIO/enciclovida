class IUCNService

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

  def dameRiesgo(opc={})
    resp = Rails.cache.fetch("iucn_#{opc[:id]}", expires_in: eval(CONFIG.cache.iucn)) do
      iucn = consultaRiesgo(opc)
      I18n.t("iucn_ws.#{iucn.estandariza}", :default => iucn) if iucn.present?
    end

    resp
  end

end

