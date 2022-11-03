class MacaulayService

  def dameMedia_nc(taxonNC, type, page=1, min_page_size = 20)
    cornell = Rails.env.production? ? CONFIG.cornell.api : CONFIG.cornell.api_rp

    taxon_escape = ERB::Util.url_encode(taxonNC)
    url = "#{cornell}sciName=#{taxon_escape}&mediaType=#{type}&taxaLocale=es&count=#{min_page_size}"
    uri = URI.parse(url)
    req = Net::HTTP::Get.new(uri.to_s)
    req['key'] = CONFIG.cornell.key
    
    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      res = http.request(req)

      if res.body.present?
        jres = JSON.parse(res.body) 
        #Si la  especie no es encontrada, Macaulay arroja un 404 :D
        jres = [{msg: "No se encontró coincidencia para #{taxonNC}"}] if jres.class == Hash && jres["message"].present?
      else
        jres = [{msg: "No se encontró coincidencia para #{taxonNC}"}]
      end

      jres
    rescue => e
      [{msg: "Hubo algun error en la solicitud: #{e} \n intente de nuevo más tarde"}]
    end
  end

end
