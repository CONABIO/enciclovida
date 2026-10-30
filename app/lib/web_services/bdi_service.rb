
module WebServices
  class BDIService < BaseService
    ALBUM_ILUSTRACIONES = "5035-Ilustraciones".freeze
    ALBUM_USOS          = "5010-Usos".freeze
    ALBUM_VIDEOS        = "5121-Video".freeze

    attr_accessor :assets, :num_assets, :jres, :campo, :type,
                  :nombre_cientifico, :album, :albumes,
                  :autor_campo, :autor, :solo_num_assets

    def initialize(opts = {})
      @campo             = opts[:campo].presence || "q"
      @nombre_cientifico = opts[:nombre_cientifico]
      @album             = opts[:album]
      @autor_campo       = opts[:autor_campo]
      @autor             = opts[:autor]
      @type              = opts[:type]
      @solo_num_assets   = opts[:solo_num_assets]

      @albumes    = []
      @assets     = []
      @jres       = []
      @num_assets = 0
    end

    def dame_fotos
      reiniciar_resultados
      limpia_nombre_cientifico
      fotos_album

      return assets if jres.blank?

      jres.each do |item|
        next unless item.is_a?(Hash)

        foto = construir_foto(item)
        assets << foto if foto
      end

      assets
    end

    def dame_num_fotos
      reiniciar_resultados
      limpia_nombre_cientifico
      lista_albumes
      fotos_totales
    end

    private

    def bdi_url
      ENV.fetch("BDI_API_URL") {
        CONFIG.bdi_imagenes
      }.to_s.chomp("/")
    end

    def bdi_recursos_url
      ENV.fetch("BDI_RECURSOS_URL") {
        CONFIG.enciclovida_url
      }.to_s.chomp("/")
    end

    def reiniciar_resultados
      self.assets = []
      self.albumes = []
      self.jres = []
      self.num_assets = 0
    end

    def consulta_api(opts = {})
      archives = opts[:archives] == true

      path =
        if archives
          "/fotoweb/archives/"
        else
          return [] if album.blank?

          "/fotoweb/archives/#{album}/"
        end

      uri = URI.parse("#{bdi_url}#{path}")

      parametros = {
        campo => nombre_cientifico.to_s
      }

      if autor_campo.present? && autor.present?
        parametros[autor_campo] = autor
      end

      uri.query = URI.encode_www_form(parametros)

      accept =
        if archives
          "application/json"
        else
          "application/vnd.fotoware.assetlist+json"
        end

      respuesta = get_json(
        uri.to_s,
        headers: { "Accept" => accept }
      )

      self.jres =
        if respuesta.is_a?(Hash)
          respuesta["data"].is_a?(Array) ? respuesta["data"] : []
        elsif respuesta.is_a?(Array)
          respuesta
        else
          []
        end

      self.num_assets = jres.size unless archives || opts[:no_contar]

      jres

    rescue BaseService::RequestError, URI::InvalidURIError => e
      Rails.logger.error(
        "[BDI] Error consultando #{path}: #{e.class} - #{e.message}"
      )

      self.jres = []
      self.num_assets = 0 unless opts[:no_contar]

      []
    end

    def lista_albumes
      self.albumes = []

      respuesta = consulta_api(archives: true)

      respuesta.each do |item|
        next unless item.is_a?(Hash)

        cantidad = item["assetCount"].to_i
        next if cantidad.zero?
        next if item["name"].to_s.casecmp("Usos").zero?

        href = item["href"]
        next if href.blank?

        albumes << {
          nombre_album: item["name"],
          url: construir_url(bdi_url, href),
          num_assets: cantidad
        }
      end

      albumes.sort_by! { |item| -item[:num_assets] }
      albumes
    end

    def fotos_album
      case album.to_s.downcase
      when "usos"
        self.album = ALBUM_USOS
        consulta_api

      when "ilustraciones"
        self.album = ALBUM_ILUSTRACIONES
        consulta_api

      else
        lista_albumes
        fotos_totales

        primer_album = albumes.first
        return if primer_album.blank?

        self.album = extraer_album_id(primer_album[:url])
        return if album.blank?

        consulta_api(no_contar: true)
        albumes.shift
      end
    end

    def construir_foto(item)
      previews = item["previews"]
      return nil unless previews.is_a?(Array)

      vistas = previews.select do |preview|
        preview.is_a?(Hash) && preview["href"].present?
      end

      return nil if vistas.empty?

      grande  = previews.dig(3, "href") rescue nil
      mediana = previews.dig(7, "href") rescue nil
      pequena = previews.dig(10, "href") rescue nil

      grande  ||= vistas.last["href"]
      mediana ||= vistas[vistas.length / 2]["href"]
      pequena ||= vistas.first["href"]

      foto = Photo.new

      foto.large_url = construir_url(bdi_recursos_url, grande)
      foto.medium_url = construir_url(bdi_recursos_url, mediana)
      foto.square_url = construir_url(bdi_recursos_url, pequena)

      foto.native_page_url = construir_url(
        bdi_url,
        item["href"]
      )

      metadata = item["metadata"] || {}

      foto.license = valor_metadata(metadata, "340") || "Sin licencia"

      foto.native_realname =
        valor_metadata(metadata, "80") || "Anónimo"

      foto
    end

    def valor_metadata(metadata, codigo)
      valor = metadata.dig(codigo, "value")
      valor = valor.first if valor.is_a?(Array)
      valor.presence
    end
    
    def construir_url(base, ruta)
      return nil if ruta.blank?
      ruta = ruta.to_s.strip
      uri = URI.parse(ruta)
      if uri.absolute?
        return uri.to_s if uri.is_a?(URI::HTTPS)
        return nil
      end
      if ruta.start_with?("//")
        return "https:#{ruta}"
      end
      URI.join("#{base}/", ruta.sub(%r{\A/+}, "")).to_s
    rescue URI::InvalidURIError, ArgumentError
      nil
    end

    def extraer_album_id(url)
      uri = URI.parse(url.to_s)

      match = uri.path.match(
        %r{/fotoweb/archives/([^/]+)}
      )

      match && match[1]
    rescue URI::InvalidURIError
      nil
    end

    def limpia_nombre_cientifico
      return if nombre_cientifico.blank?

      self.nombre_cientifico =
        nombre_cientifico.to_s.limpiar(tipo: "ssp")
    end

    def fotos_totales
      self.num_assets = albumes.sum do |item|
        item[:num_assets].to_i
      end
    end
  end
end
