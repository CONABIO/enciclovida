class MacaulayService

  def dameFotos(taxonCode)
    ebird = CONFIG.ebird.api

    url = "#{ebird}#{taxonCode}&mediaType=p"
    url_escape = URI.escape(url)
    uri = URI.parse(url_escape)
    req = Net::HTTP::Get.new(uri.to_s)
    puts '-----------'+uri.to_s
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

  def dameVideos(taxonCode)
    ebird = CONFIG.ebird.api

    url = "#{ebird}#{taxonCode}&mediaType=v"
    url_escape = URI.escape(url)
    uri = URI.parse(url_escape)
    req = Net::HTTP::Get.new(uri.to_s)
    puts '-----------'+uri.to_s
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

  def dameAudios(taxonCode)
    ebird = CONFIG.ebird.api

    url = "#{ebird}#{taxonCode}&mediaType=a"
    url_escape = URI.escape(url)
    uri = URI.parse(url_escape)
    req = Net::HTTP::Get.new(uri.to_s)
    puts '-----------'+uri.to_s
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

