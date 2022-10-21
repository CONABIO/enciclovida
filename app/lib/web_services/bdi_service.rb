class BDIService

  ALBUM_ILUSTRACIONES = '5035-Ilustraciones'.freeze
  ALBUM_USOS = '5010-Usos'.freeze
  ALBUM_VIDEOS = '5121-Video'.freeze

  attr_accessor :assets, :num_assets, :jres, :campo, :type, :nombre_cientifico, :album, :albumes, :autor_campo, :autor, :solo_num_assets

  def initialize(opts)
    self.campo = opts[:campo] || 528
    self.nombre_cientifico = opts[:nombre_cientifico]
    self.album = opts[:album]
    self.albumes = []
    self.autor_campo = opts[:autor_campo]
    self.autor = opts[:autor]
    self.type = opts[:type]
    self.jres = nil
    self.assets = []  # Puede ser foto, video o albumes
    self.num_assets = 0
  end

  def dame_fotos
    bdi_rp = CONFIG.enciclovida_url
    bdi_url = CONFIG.bdi_imagenes
    limpia_nombre_cientifico
    fotos_album
    return if num_assets == 0

    jres.each do |f|
      foto = Photo.new
      foto.large_url = bdi_rp + f['previews'][3]['href']
      foto.medium_url = bdi_rp + f['previews'][7]['href']
      foto.native_page_url = bdi_url + f['href']
      foto.license = f['metadata']['340'].present? ? f['metadata']['340']['value'] : 'Sin licencia'
      foto.square_url = bdi_rp + f['previews'][10]['href']
      foto.native_realname = f['metadata']['80'].present? ? f['metadata']['80']['value'].first : "Anónimo"
      self.assets << foto
    end
  end

  def dame_num_fotos
    limpia_nombre_cientifico
    lista_albumes
    fotos_totales
  end

  # Método para recuperar los videos
  def dame_videos(opts)
    bdi_rp = CONFIG.enciclovida_url
    bdi_url = CONFIG.bdi_imagenes
    videos = []
    jres = videos_album(opts)

    return {:estatus => 'OK', :ultima => nil, :videos => []} unless jres['data'].any?

    jres['data'].each do |x|
      video = Video.new
      video.href_info = bdi_url + x['href']
      video.url_acces = bdi_rp + x['attributes']['videoattributes']['proxy']['videoHREF']
      video.preview_img = x['previews'].present? ? bdi + x['previews'][0]['href'] : nil
      video.autor = x['metadata']['80'].present? ? x['metadata']['80']['value'].first : "Anónimo"
      video.localidad = x['metadata']['90'].present? ? x['metadata']['90']['value'] : nil
      video.municipio = x['metadata']['300'].present? ? x['metadata']['300']['value'] : nil
      video.licencia = x['metadata']['340'].present? ? x['metadata']['340']['value'] : nil
      videos << video
    end

    if jres['paging'].present? && jres['paging']['next'].present?
      ultima = jres['paging']['last'].split('&p=').last.to_i + 1
      {:estatus => true, :ultima => ultima, :videos => videos}
    else
      {:estatus => true, :ultima => nil, :videos => videos}
    end
  end


  private

  def videos_album(opts)
    taxon = opts[:taxon]
    # Solo para el caso de los videos
    opts.merge!({album: ALBUM_VIDEOS, nombre: taxon.nombre_cientifico, campo: 'q'})
    tiene_fotos?(opts)
  end

  # Regresa la lista de albumes con al menos una foto en orden por numero de fotos
  def lista_albumes
    consulta_api({archives: true})

    jres.each do |a|
      # Evitamos los albumes sin fotos y los de usos que tienen su propio apartado
      next if a["assetCount"] == 0 || a["name"] == "Usos"  
      self.albumes << { nombre_album: a["name"], url: "#{CONFIG.bdi_imagenes}#{a["href"]}", num_assets: a["assetCount"] }
    end

    albumes.sort_by! { |k| -k[:num_assets] }
  end

  def consulta_api(opts={})
    if opts[:archives]
      url = "#{CONFIG.bdi_imagenes}/fotoweb/archives/?#{campo}='#{nombre_cientifico}'"
      accept = 'application/json'
    else
      url = "#{CONFIG.bdi_imagenes}/fotoweb/archives/#{album}/?#{campo}='#{nombre_cientifico}'"
      accept = 'application/vnd.fotoware.assetlist+json'
    end

    url << "&#{autor_campo}=#{autor}" if autor_campo.present? && autor.present?

    url_escape = URI.escape(url)
    uri = URI.parse(url_escape)
    req = Net::HTTP::Get.new(uri.to_s)
    req['Accept'] = accept

    begin
      res = Net::HTTP.start(uri.host, uri.port) {|http| http.request(req) }
      jres = JSON.parse(res.body)
      self.jres = jres["data"]
      self.num_assets = jres.count if !opts[:archives] && !opts[:no_contar]
    rescue
      Rails.logger.error "Falló en la consulta: #{uri} "
    end
  end

  # Regresa las 25 primeras fotos de los albumes que mas tiene fotos y una la lista de los demas albumes no vacios
  def fotos_album
    # Solo de usos o vacio
    if album == "usos"
      self.album = ALBUM_USOS
      consulta_api
      return
    end
    
    # Solo ilustraciones o lo demas que tenga
    if album == "ilustraciones"
      self.album = ALBUM_ILUSTRACIONES
      consulta_api
      return if num_assets > 0  # Regresa solo en el caso de encontrar fotos
    end
    
    # Busca en los demas albumes
    lista_albumes
    fotos_totales
    return if num_assets == 0  # No hay fotos, ni pex!

    dame_album_id(albumes.first[:url])  # El primer album siempre tiene mas fotos
    consulta_api({no_contar: true})
    albumes.shift  # Quita el primer album del que trae las fotos de los demas albumes
  end

  def dame_album_id(url)
    self.album = url.split("/")[5]
  end

  def limpia_nombre_cientifico
    self.nombre_cientifico.limpiar(tipo: 'ssp')
  end

  # Regresa el numero total de fotos en todos los albumes
  def fotos_totales
    self.num_assets = albumes.map{|k| k[:num_assets] }.sum
  end  

end

