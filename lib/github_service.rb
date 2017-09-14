class GithubService

  def damePulls(numero=nil)
    @github = CONFIG.github.api


    url = "#{@github}/pulls?state=closed"
    url_escape = URI.escape(url)
    uri = URI.parse(url_escape)
    req = Net::HTTP::Get.new(uri.to_s)
    req['Accept'] = 'application/vnd.github.v3+json'

    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")
      res = http.request(req)

      jres = JSON.parse(res.body)
      jres[0..4] if jres.any?
    rescue => e
      nil
    end
  end

  def dameIssuesNF
    @github = CONFIG.github.api


    url = "#{@github}/issues?state=all&label=new%20feature"
    url_escape = URI.escape(url)
    uri = URI.parse(url_escape)
    req = Net::HTTP::Get.new(uri.to_s)
    req['Accept'] = 'application/vnd.github.v3+json'

    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")
      res = http.request(req)

      jres = JSON.parse(res.body)
      jres[0..4] if jres.any?
    rescue => e
      nil
    end
  end

end