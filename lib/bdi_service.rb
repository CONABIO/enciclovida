class BDIService

  ALBUM_ANIMALES = {8002485 => '5006-Aves', 8002478 => '5009-Peces', 8002483 => '5008-Mamíferos',
                    8000009 => '5001-Reptiles', 8002484 => '5007-Anfibios', 8002480 => '5107-Tiburones%20y%20Rayas', 7000005 => '5004-Microorganismos', 7000003 => '5004-Microorganismos', 1000006 => '5005-Invertebrados', 4000006 => '5005-Invertebrados', 4000007 => '5005-Invertebrados', 4000008 => '5005-Invertebrados', 4000009 => '5005-Invertebrados', 4000010 => '5005-Invertebrados', 4000011 => '5005-Invertebrados', 4000012 => '5005-Invertebrados', 4000013 => '5005-Invertebrados', 4000014 => '5005-Invertebrados', 4004301 => '5005-Invertebrados', 4004389 => '5005-Invertebrados', 4004403 => '5005-Invertebrados', 4004553 => '5005-Invertebrados', 4004600 => '5005-Invertebrados', 4007072 => '5005-Invertebrados', 4007472 => '5005-Invertebrados', 8002472 => '5005-Invertebrados', 10000006 => '5005-Invertebrados'}
  ALBUM_ANIMALES_GLOBAL = ['5037-Colección%20Zoológica']

  ALBUM_PLANTAS = {3000004 => '5002-Hongos', 6000010 => '5018-Cícadas', 6000007 => '5017-Musgos-Helechos', 6000008 => '5017-Musgos-Helechos', 6000009 => '5021-Pinos%20y%20Cedros'}
  ALBUM_PLANTAS_GLOBAL = ['5023-Plantas', '5038-Colección%20Botánica']

  def dameFotos(opts)
    bdi = CONFIG.bdi_imagenes
    fotos = []
    jres = fotos_album(opts)

    jres['data'].each do |x|
      foto = Photo.new
      foto.large_url = bdi+x['previews'][3]['href']
      foto.medium_url = bdi+x['previews'][7]['href']
      foto.native_page_url = bdi+x['href']
      foto.license = x['metadata']['340'].present? ? x['metadata']['340']['value'] : 'Sin licencia'
      foto.square_url = bdi+x['previews'][10]['href']
      foto.native_realname = x['metadata']['80'].present? ? x['metadata']['80']['value'].first : "Anónimo"
      fotos << foto
    end

    if jres['paging'].present? && jres['paging']['next'].present?
      ultima = jres['paging']['last'].split('&p=').last.to_i + 1
      {:estatus => 'OK', :ultima => ultima, :fotos => fotos}
    else
      {:estatus => 'OK', :ultima => nil, :fotos => fotos}
    end
  end

  # Compruebo en los albunes para mandar una respuesta no vacia
  def tiene_fotos?(opts)
    url = "#{CONFIG.bdi_imagenes}/fotoweb/archives/#{opts[:album]}/?#{opts[:campo]}='#{opts[:nombre]}'"
    url << "&p=#{opts[:pagina]-1}" if opts[:pagina]
    url_escape = URI.escape(url)
    uri = URI.parse(url_escape)

    req = Net::HTTP::Get.new(uri.to_s)
    req['Accept'] = 'application/vnd.fotoware.assetlist+json'

    begin
      res = Net::HTTP.start(uri.host, uri.port) {|http| http.request(req) }
      jres = JSON.parse(res.body)
      jres = {'data' => []} unless jres['data'].present?
    rescue
      jres = {'data' => []}
    end

    jres
  end

  # Las fotos de acuerdo al album al que pertenece en BDI
  def fotos_album(opts)
    taxon = opts[:taxon]
    reino = taxon.root.nombre_cientifico
    ancestros = taxon.path_ids

    case reino
      when 'Animalia'
        (ALBUM_ANIMALES.keys & ancestros).each do |taxon_id|
          opts.merge!({album: ALBUM_ANIMALES[taxon_id], nombre: taxon.nombre_cientifico})
          jres = tiene_fotos?(opts)
          return jres if jres.any?
        end

        # Si llego a este punto quiere decir que tengo que probar con los globales
        ALBUM_ANIMALES_GLOBAL.each do |album|
          opts.merge!({album: album, nombre: taxon.nombre_cientifico})
          jres = tiene_fotos?(opts)
          return jres if jres.any?
        end

      else
        (ALBUM_PLANTAS.keys & ancestros).each do |taxon_id|
          opts.merge!({album: ALBUM_PLANTAS[taxon_id], nombre: taxon.nombre_cientifico})
          jres = tiene_fotos?(opts)
          return jres if jres.any?
        end

        # Si llego a este punto quiere decir que tengo que probar con los globales
        ALBUM_PLANTAS_GLOBAL.each do |album|
          opts.merge!({album: album, nombre: taxon.nombre_cientifico})
          jres = tiene_fotos?(opts)
          return jres if jres.any?
        end
    end

  end
end

