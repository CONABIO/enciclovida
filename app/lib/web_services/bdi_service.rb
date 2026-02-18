class BDIService
  ALBUM_ILUSTRACIONES = '5035-Ilustraciones'.freeze
  ALBUM_USOS = '5010-Usos'.freeze
  ALBUM_VIDEOS = '5121-Video'.freeze

  attr_accessor :assets, :num_assets, :jres, :campo, :type,
                :nombre_cientifico, :album, :albumes, :autor_campo, :autor, :solo_num_assets

  def initialize(opts = {})
    self.campo              = opts[:campo] || 'q'
    self.nombre_cientifico  = opts[:nombre_cientifico]
    self.album              = opts[:album]
    self.albumes           = []
    self.autor_campo       = opts[:autor_campo]
    self.autor             = opts[:autor]
    self.type              = opts[:type]
    self.jres              = nil
    self.assets            = []
    self.num_assets        = 0
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

  def lista_albumes
    consulta_api(archives: true)
    return [] unless jres.is_a?(Array) && jres.present?

    jres.each do |a|
      asset_count = a['assetCount'].to_i rescue 0
      next if asset_count.zero? || a['name'] == "Usos"

      href = a['href'] || next
      self.albumes << {
        nombre_album: a['name'],
        url:          "#{CONFIG.bdi_imagenes}#{href}",
        num_assets:   asset_count
      }
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

  def fotos_album
    case album.to_s.downcase
    when "usos"
      self.album = ALBUM_USOS
      consulta_api
    when "ilustraciones"
      self.album = ALBUM_ILUSTRACIONES
      consulta_api
      return if num_assets.to_i > 0
    else
      lista_albumes
      fotos_totales
      return if num_assets.to_i.zero?

      first = albumes.first
      return unless first

      dame_album_id(first[:url])
      consulta_api(no_contar: true)
      albumes.shift
    end
  end

  def build_url(base, hash_or_nil, key)
    path = hash_or_nil&.[](key)
    path.present? ? "#{base}#{path}" : nil
  end

  def dame_album_id(url)
    # ejemplo: /fotoweb/archives/5035-Ilustraciones/
    parts = url.split("/")
    self.album = parts[5]
  rescue
    self.album = nil
  end

  def limpia_nombre_cientifico
    nombre_cientifico&.limpiar(tipo: 'ssp')
  end

  def fotos_totales
    self.num_assets = albumes.map { |k| k[:num_assets].to_i }.sum
  end

  def api_accept_header(opts)
    opts[:archives] ? 'application/json' : 'application/vnd.fotoware.assetlist+json'
  end
end