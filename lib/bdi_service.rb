class BDIService

  ALBUM_ANIMALES = {22655 => '5006-Aves', 213482 => '5009-Peces', 22653 => '5008-Mamíferos',
                    22647 => '5001-Reptiles', 22654 => '5007-Anfibios', 22650 => '5107-Tiburones%20y%20Rayas', 5 => '5004-Microorganismos', 3 => '5004-Microorganismos', 129550 => '5005-Invertebrados', 40657 => '5005-Invertebrados', 40658 => '5005-Invertebrados', 40659 => '5005-Invertebrados', 40660 => '5005-Invertebrados', 40661 => '5005-Invertebrados', 40662 => '5005-Invertebrados', 40663 => '5005-Invertebrados', 40664 => '5005-Invertebrados', 40665 => '5005-Invertebrados', 40666 => '5005-Invertebrados', 40667 => '5005-Invertebrados', 40668 => '5005-Invertebrados', 40669 => '5005-Invertebrados', 40670 => '5005-Invertebrados', 40671 => '5005-Invertebrados', 40672 => '5005-Invertebrados', 213408 => '5005-Invertebrados', 16910 => '5005-Invertebrados'}
  ALBUM_ANIMALES_GLOBAL = ['5037-Colección%20Zoológica']

  ALBUM_PLANTAS = {4 => '5002-Hongos', 6000010 => '5018-Cícadas', 135296 => '5017-Musgos-Helechos', 6000008 => '5017-Musgos-Helechos', 6000009 => '5021-Pinos%20y%20Cedros'}
  ALBUM_PLANTAS_GLOBAL = %w(5023-Plantas 5038-Colección%20Botánica)

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
      {:estatus => true, :ultima => ultima, :fotos => fotos}
    else
      {:estatus => true, :ultima => nil, :fotos => fotos}
    end
  end

  # Compruebo en los albunes para mandar una respuesta no vacia
  def tiene_fotos?(opts)
    jres = arma_y_consulta_url(opts)
    if !jres['data'].present?
      opts[:campo] = 'q'
      jres = arma_y_consulta_url(opts)
      jres = {'data' => []} unless jres['data'].present?
    end
    jres
  end

  def arma_y_consulta_url(opts)
    nombre = opts[:nombre].limpiar(true)
    url = "#{CONFIG.bdi_imagenes}/fotoweb/archives/#{opts[:album]}/?#{opts[:campo]}='#{nombre}'"
    url << "&p=#{opts[:pagina]-1}" if opts[:pagina]
    url_escape = URI.escape(url)
    uri = URI.parse(url_escape)
    req = Net::HTTP::Get.new(uri.to_s)
    req['Accept'] = 'application/vnd.fotoware.assetlist+json'

    begin
      res = Net::HTTP.start(uri.host, uri.port) {|http| http.request(req) }
      JSON.parse(res.body)
    rescue
      {'data' => []}
    end

  end

  # Las fotos de acuerdo al album al que pertenece en BDI
  def fotos_album(opts)
    taxon = opts[:taxon]
    reino = taxon.root.nombre_cientifico.strip
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

