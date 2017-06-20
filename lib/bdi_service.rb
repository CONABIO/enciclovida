class BDIService

  def dameFotos(nombre_cientifico, url=nil)
    bdi = 'http://bdi.conabio.gob.mx'
    fotos = []

    if url.nil?
      url = URI.parse("http://bdi.conabio.gob.mx/fotoweb/archives/5000-Banco%20de%20Im%C3%A1genes/?528='#{nombre_cientifico.gsub(" ","+")}'")
    else
      url = URI.parse(url)
    end

    req = Net::HTTP::Get.new(url.to_s)
    req['Accept'] = 'application/vnd.fotoware.assetlist+json'

    begin
      res = Net::HTTP.start(url.host, url.port) {|http| http.request(req) }
      jres = JSON.parse(res.body)
    rescue => e
      {:status => 'error', :msg => e}
    end

    jres['data'].each do |x|
      fotos << Photo.new({original_url: bdi+x['previews'][3]['href'],native_page_url: bdi+x['href'],license: x['metadata']['340']['value'],square_url: bdi+x['previews'][10]['href']})
    end

    if jres['paging'].present? && jres['paging']['next'].present?
      {:status => 'OK', :siguiente => bdi+jres['paging']['next'], :ultima => bdi+jres['paging']['last'], :fotos => fotos}
    else
      {:status => 'OK', :siguiente => '', :fotos => fotos}
    end

  end

end

