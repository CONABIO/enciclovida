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
      {:estatus => 'error', :msg => e}
    end

    jres['data'].each do |x|
      fotos << Photo.new({large_url: bdi+x['previews'][3]['href'],medium_url: bdi+x['previews'][0]['href'],native_page_url: bdi+x['href'],license: x['metadata']['340']['value'],square_url: bdi+x['previews'][10]['href'], native_realname: x['metadata']['80']['value'].first})
    end

    if jres['paging'].present? && jres['paging']['next'].present?
      {:estatus => 'OK', :siguiente => bdi+jres['paging']['next'], :ultima => bdi+jres['paging']['last'], :fotos => fotos}
    else
      {:estatus => 'OK', :siguiente => '', :fotos => fotos}
    end
  end
end

