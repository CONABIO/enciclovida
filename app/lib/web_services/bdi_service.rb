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
    limpia_nombre_cientifico
    fotos_album

    return if assets.empty?

    # Asegurarse de que jres es un array antes de iterar
    Array(jres).each do |f|
      # usar navegación segura (&.) para prevenir nil
      previews = f['previews'] || []
      metadata = f['metadata'] || {}

      foto = Photo.new
      foto.large_url       = build_url(CONFIG.enciclovida_url, previews[3], 'href')
      foto.medium_url      = build_url(CONFIG.enciclovida_url, previews[7], 'href')
      foto.native_page_url = build_url(CONFIG.bdi_imagenes, f, 'href')
      foto.license         = metadata.dig('340', 'value') || 'Sin licencia'
      foto.square_url      = build_url(CONFIG.enciclovida_url, previews[10], 'href')
      # si metadata['80']['value'] no existe o no es array, fallback a "Anónimo"
      foto.native_realname = metadata.dig('80', 'value')&.first || "Anónimo"

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

  def consulta_api(opts = {})
    url = if opts[:archives]
            "#{CONFIG.bdi_imagenes}/fotoweb/archives/?#{campo}=#{nombre_cientifico}"
          else
            "#{CONFIG.bdi_imagenes}/fotoweb/archives/#{album}/?#{campo}=#{nombre_cientifico}"
          end

    url << "&#{autor_campo}=#{autor}" if autor_campo.present? && autor.present?

    begin
      url_escape = URI::DEFAULT_PARSER.escape(url)
      res = RestClient.get url_escape, accept: api_accept_header(opts)
      body = res.body
      parsed = JSON.parse(body) rescue nil
      self.jres = parsed&.[]("data")
      # actualizar num_assets sólo si data es un arreglo (y sólo en consulta “normal”)
      self.num_assets = jres.size if jres.is_a?(Array) && !opts[:archives] && !opts[:no_contar]
    rescue => e
      Rails.logger.error "[BDIService] Error al consultar #{url_escape}: #{e.class} -- #{e.message}"
      self.jres = nil
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