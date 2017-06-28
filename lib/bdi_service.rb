class BDIService

  def dameFotos(nombre_cientifico, p=nil)
    bdi = CONFIG.bdi_imagenes
    fotos = []

    url = "#{bdi}/fotoweb/archives/5000-Banco de Imágenes/?528='#{nombre_cientifico}'"
    url << "&p=#{p-1}" if p
    url_escape = URI.escape(url)
    uri = URI.parse(url_escape)

    req = Net::HTTP::Get.new(uri.to_s)
    req['Accept'] = 'application/vnd.fotoware.assetlist+json'

    begin
      res = Net::HTTP.start(uri.host, uri.port) {|http| http.request(req) }
      jres = JSON.parse(res.body)
    rescue => e
      jres = {'data' => []}
      {:estatus => 'error', :msg => e}
    end

    jres['data'].each do |x|
      fotos << Photo.new({large_url: bdi+x['previews'][3]['href'],
                           medium_url: bdi+x['previews'][7]['href'],
                           native_page_url: bdi+x['href'],
                           license: x['metadata']['340'].present? ? x['metadata']['340']['value'] : 'Sin licencia',
                           square_url: bdi+x['previews'][10]['href'],
                           native_realname: x['metadata']['80'].present? ? x['metadata']['80']['value'].first : "Anónimo"})
    end

    if jres['paging'].present? && jres['paging']['next'].present?
      ultima = jres['paging']['last'].split('&p=').last.to_i + 1
      {:estatus => 'OK', :ultima => ultima, :fotos => fotos}
    else
      {:estatus => 'OK', :ultima => nil, :fotos => fotos}
    end
  end
end

