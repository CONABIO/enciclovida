class BDIService

    ALBUM_ILUSTRACIONES = '5035-Ilustraciones'.freeze
  ALBUM_USOS = '5010-Usos'.freeze
  ALBUM_VIDEOS = '5121-Video'.freeze

  attr_accessor :assets, :num_assets, :jres, :campo, :type, :nombre_cientifico, :album, :albumes, :autor_campo, :autor, :solo_num_assets

  def initialize(opts)
    # self.campo = opts[:campo] || 528
    self.campo = opts[:campo] || 'q'
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


  private

  # Regresa la lista de albumes con al menos una foto en orden por numero de fotos
  def lista_albumes
    consulta_api({archives: true})
    return unless jres.present?           # ⚠️ Si jres es nil o vacío, salir

    jres.each do |a|
      next if a["assetCount"].zero? || a["name"] == "Usos"
      self.albumes << { nombre_album: a["name"], url: "#{CONFIG.bdi_imagenes}#{a["href"]}", num_assets: a["assetCount"] }
    end

    albumes.sort_by! { |k| -k[:num_assets] }
  end

  def consulta_api(opts={})
    if opts[:archives]
      url = "#{CONFIG.bdi_imagenes}/fotoweb/archives/?#{campo}=#{nombre_cientifico}"
      accept = 'application/json'
    else
      url = "#{CONFIG.bdi_imagenes}/fotoweb/archives/#{album}/?#{campo}=#{nombre_cientifico}"
      accept = 'application/vnd.fotoware.assetlist+json'
    end

    url << "&#{autor_campo}=#{autor}" if autor_campo.present? && autor.present?

    begin
      url_escape = URI::DEFAULT_PARSER.escape(url)
      res = RestClient.get url_escape, accept: accept
      jres = JSON.parse(res.body)
      self.jres = jres["data"]
      self.num_assets = jres.count if !opts[:archives] && !opts[:no_contar]    
    rescue => e
      Rails.logger.error "Falló en la consulta con #{url_escape}: #{e.inspect} "
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

