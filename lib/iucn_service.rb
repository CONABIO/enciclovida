class IUCNService

  def dameRiesgo(opts)
    @iucn = CONFIG.iucn.api
    @token = CONFIG.iucn.token

    url = "#{@iucn}/api/v3/species/#{opts[:nombre]}?token=#{@token}"
    url_escape = URI.escape(url)
    uri = URI.parse(url_escape)
    req = Net::HTTP::Get.new(uri.to_s)
    begin
      res = Net::HTTP.start(uri.host, uri.port) {|http| http.request(req) }
      jres = JSON.parse(res.body)['result']
      jres[0]["category"] if jres.any?
    rescue => e
      nil
    end
  end

end

