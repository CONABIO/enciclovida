class Proveedor < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.ev}.proveedores"

  belongs_to :especie
  attr_accessor :totales, :observaciones, :observacion, :ejemplares, :ejemplar, :jres

  # REVISADO: Las fotos de referencia de naturalista son una copia de las fotos de referencia de enciclovida
  def fotos_naturalista
    ficha_naturalista_api_nodejs
    return unless jres[:estatus]

    fotos = jres[:ficha]['taxon_photos']
    self.jres = jres.merge({ fotos: fotos })
  end

  # REVISADO: Todos los nombres comunes de la ficha de naturalista
  def nombres_comunes_naturalista
    ficha_naturalista_api_nodejs
    return unless jres[:estatus]

    nombres_comunes = jres[:ficha]['names']
    self.jres = jres.merge({ nombres_comunes: nombres_comunes })
  end

  # REVISADO: Consulta la ficha de naturalista por medio de su API nodejs
  # TODO se requiere un boton de borrar cache
  def ficha_naturalista_api_nodejs
    if Rails.cache.exist?("ficha_naturalista_#{especie_id}")
      self.jres = Rails.cache.fetch("ficha_naturalista_#{especie_id}")
      return
    end

    Rails.cache.fetch("ficha_naturalista_#{especie_id}", expires_in: eval(CONFIG.cache.ficha_naturalista)) do
      if naturalista_id.blank?
        t = especie
        t.ficha_naturalista_por_nombre
        self.jres = t.jres

        return unless jres.present?
      end

      begin
        resp = RestClient.get "#{CONFIG.inaturalist_api}/taxa/#{naturalista_id}?all_names=true"
        ficha = JSON.parse(resp)

        if ficha['total_results'] == 1
          { estatus: true, ficha: ficha['results'][0] }
        else
          { estatus: false, msg: 'Tiene más de un resultado, solo debería ser uno por ser ficha' }
        end

      rescue => e
        { estatus: false, msg: e }
      end
    end  # End cache.fetch

    if Rails.cache.exist?("ficha_naturalista_#{especie_id}")
      self.jres = Rails.cache.fetch("ficha_naturalista_#{especie_id}")
    else
      self.res = { estatus: false, msg: 'Error en el cache' }
    end
  end

  # REVISADO: Devuelve una lista de todas las URLS asociadas a los geodatos
  def geodatos
    geodatos = {}
    geodatos[:cuales] = []

    if geoserver_info.present?
      info = JSON.parse(geoserver_info)

      geodatos[:cuales] << 'geoserver'
      geodatos[:geoserver_url] = CONFIG.geoserver_url.to_s
      geodatos[:geoserver_descargas_url] = []

      info.each do |mapa, datos|
        geodatos[:geoserver_descargas_url] << { layers: datos['layers'], styles: datos['styles'], bbox: datos['bbox'], mapa: mapa, anio: datos['anio'], autor: datos['autor'], geoportal_url: datos['geoportal_url'] }
      end
    end

    # Para las descargas del SNIB
    url = "#{CONFIG.site_url}especies/#{especie_id}/ejemplares-snib"

    resp = ejemplares_snib('.json')
    if resp[:estatus]
      geodatos[:cuales] << 'snib'
      geodatos[:snib_json] = "#{url}.json"
    end

    resp = ejemplares_snib('.kml')
    if resp[:estatus]
      geodatos[:cuales] << 'snib'
      geodatos[:snib_kml] = "#{url}.kml"
    end

    resp = ejemplares_snib('.kmz')
    if resp[:estatus]
      geodatos[:cuales] << 'snib'
      geodatos[:snib_kmz] = "#{url}.kmz"
    end

    resp = ejemplares_snib('.json', true)
    if resp[:estatus]
      geodatos[:cuales] << 'snib'
      geodatos[:snib_mapa_json] = "#{CONFIG.site_url}geodatos/#{especie_id}/#{resp[:ruta].split('/').last}"
    end

    # Para las descargas de naturalista
    url = "#{CONFIG.site_url}especies/#{especie_id}/observaciones-naturalista"

    resp = observaciones_naturalista('.json')
    if resp[:estatus]
      geodatos[:cuales] << 'naturalista'
      geodatos[:naturalista_json] = "#{url}.json"
    end

    resp = observaciones_naturalista('.kml')
    if resp[:estatus]
      geodatos[:cuales] << 'naturalista'
      geodatos[:naturalista_kml] = "#{url}.kml"
    end

    resp = observaciones_naturalista('.kmz')
    if resp[:estatus]
      geodatos[:cuales] << 'naturalista'
      geodatos[:naturalista_kmz] = "#{url}.kmz"
    end

    resp = observaciones_naturalista('.json', true)
    if resp[:estatus]
      geodatos[:cuales] << 'naturalista'
      geodatos[:naturalista_mapa_json] = "#{CONFIG.site_url}geodatos/#{especie_id}/#{resp[:ruta].split('/').last}"
    end

    ruta_registros = carpeta_geodatos.join("registros_#{especie_id}_todos.json")
    if File.exist?(ruta_registros)
      geodatos[:registros_todos] = "#{CONFIG.site_url}geodatos/#{especie_id}/registros_#{especie_id}_todos.json"
    end

    geodatos[:cuales] = geodatos[:cuales].uniq
    geodatos
  end


  private

  # REVISADO: Crea o devuleve la capreta de los geodatos
  def carpeta_geodatos
    carpeta = Rails.root.join('public', 'geodatos', especie_id.to_s)
    FileUtils.mkpath(carpeta, :mode => 0755) unless File.exists?(carpeta)
    carpeta
  end

  # REVISADO: Borra el json, kml, kmz del taxon en cuestion, ya sea observaciones o ejemplares
  def borrar_geodata(tipo)
    ruta = Rails.root.join('public', 'geodatos', especie_id.to_s, "#{tipo}*")
    archivos = Dir.glob(ruta)

    archivos.each do |a|
      File.delete(a)
    end
  end

  def photo_type(url)
    return 'FlickrPhoto' if url.include?("staticflickr\.com") || url.include?("static\.flickr\.com")
    return 'EolPhoto' if url.include? "media\.eol\.org"
    return 'NaturalistaPhoto' if url.include? "static\.inaturalist\.org"
    return 'WikimediaCommonsPhoto' if url.include? "upload\.wikimedia\.org"
  end

  def taxon_photos(datos, usuario)
    photos = []
    datos['taxon_photos'].each do |pho| #Guarda todas las fotos asociadas del taxon
      next unless pho['photo']['native_photo_id'].present?
      next unless pho['photo']['thumb_url'].present?
      next unless photo_type(pho['photo']['thumb_url']).present?

      local_photo = Photo.where(:native_photo_id => pho['photo']['native_photo_id'], :type => photo_type(pho['photo']['thumb_url']))
      photo = local_photo.count == 1 ? local_photo.first : Photo.new #Crea o actualiza la foto

      photo.usuario_id = usuario
      photo.native_photo_id = pho['photo']['native_photo_id']
      photo.square_url = pho['photo']['square_url']
      photo.thumb_url = pho['photo']['thumb_url']
      photo.small_url = pho['photo']['small_url']
      photo.medium_url = pho['photo']['medium_url']
      photo.large_url = pho['photo']['large_url']
      #photo.original_url = pho['photo']['original_url']
      photo.created_at = pho['photo']['created_at']
      photo.updated_at = pho['photo']['updated_at']
      photo.native_page_url = pho['photo']['native_page_url']
      photo.native_username = pho['photo']['native_username']
      photo.native_realname = pho['photo']['native_realname']
      photo.license = pho['photo']['license']
      photo.type = photo_type(pho['photo']['thumb_url'])
      photos << photo
    end
    photos
  end

end
