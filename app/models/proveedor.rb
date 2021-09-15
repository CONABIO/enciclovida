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
      self.jres = { estatus: false, msg: 'Error en el cache' }
    end
  end

  # Devuelve los datos de los mapas para el geoserver
  def dame_geoserver
    return self.jres = { estatus: false, msg: 'No tiene datos en el geoserver' } unless geoserver_info.present?
    info = JSON.parse(geoserver_info)
    geoserver_urls = []

    info.each do |mapa, d|
      geoserver_descarga_url = "#{CONFIG.geoserver_descarga_url}&layers=#{d['layers']}&styles=#{d['styles']}&bbox=#{d['bbox']}"
      datos = { layers: d['layers'],  anio: d['anio'], autor: d['autor'], styles: d['styles'], bbox: d['bbox'], mapa: mapa }
      geoserver_urls << { datos: datos, geoserver_descarga_url: geoserver_descarga_url, geoportal_url: d['geoportal_url'] }
    end

    self.jres = { estatus: true, geoserver_urls: geoserver_urls }
  end

  private

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
