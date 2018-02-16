class MacaulayService

  def dameMedia(taxonCode, type)
    cornell = CONFIG.cornell.api

    url = "#{cornell}speciesCode=#{taxonCode}&assetFormatCode=#{type}&taxaLocale=es"
    url_escape = URI.escape(url)
    uri = URI.parse(url_escape)
    req = Net::HTTP::Get.new(uri.to_s)
    req['key'] = CONFIG.cornell.key

    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      res = http.request(req)
      jres = JSON.parse(res.body)
      jres if jres.any?
    rescue => e
      nil
    end
  end

  def dameMedia_nc(taxonNC, type)
    cornell = CONFIG.cornell.api

    url = "#{cornell}sciName=#{taxonNC.gsub(' ','+')}&assetFormatCode=#{type}&taxaLocale=es"
    url_escape = URI.escape(url)
    uri = URI.parse(url_escape)
    req = Net::HTTP::Get.new(uri.to_s)
    req['key'] = CONFIG.cornell.key
    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      res = http.request(req)
      jres = res.body.present? ? JSON.parse(res.body) : [{msg: 'No se encontraron coincidencias'}]
      jres if jres.any?
    rescue => e
      nil
    end
  end

  def dameTaxonCode(taxonNC)

  end

  def dameMedia_ebird(taxonCode, type)
    ebird = CONFIG.ebird.api

    url = "#{ebird}#{taxonCode}&mediaType=#{type}&locale=es"
    url_escape = URI.escape(url)
    uri = URI.parse(url_escape)
    req = Net::HTTP::Get.new(uri.to_s)
    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      res = http.request(req)
      jres = JSON.parse(res.body)
      jres['results']['content'] if jres.any?
    rescue => e
      nil
    end
  end
end

