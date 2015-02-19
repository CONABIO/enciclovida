class Proveedor < ActiveRecord::Base
  belongs_to :especie

  # Saca los nombres comunes del campo naturalista_info
  def nombres_comunes
    datos = eval(naturalista_info)
    datos = datos.first if datos.is_a?(Array)
    return [] unless datos['taxon_names'].present?
    nombres_comunes_faltan = []

    # Nombres comunes de la base de catalogos
    nom_comunes = especie.nombres_comunes
    nom_comunes = nom_comunes.map(&:nombre_comun).map{ |nom| I18n.transliterate(nom).downcase }.sort if nom_comunes

    datos['taxon_names'].each do |datos_nombres|
      next unless datos_nombres['is_valid']
      next if datos_nombres['lexicon'] == 'Scientific Names'

      # Nombre comun de NaturaLista
      nombre = I18n.transliterate(datos_nombres['name']).downcase
      lengua = datos_nombres['lexicon']

      if nom_comunes.present?
        next if nom_comunes.include?(nombre)
      end
      nombres_comunes_faltan << "#{especie.catalogo_id},\"#{datos_nombres['name']}\",#{lengua},#{especie.nombre_cientifico},#{especie.categoria_taxonomica.nombre_categoria_taxonomica}"
    end

    nombres_comunes_faltan
  end

  def fotos(usuario)
    datos = eval(naturalista_info)
    datos = datos.first if datos.is_a?(Array)
    return [] unless datos['taxon_photos'].present?
    return [] if usuario.blank?

    fotos_naturalista = taxon_photos(datos, usuario)
    return [] if fotos_naturalista.length == 0
    taxon = especie
    fotos_buscador = taxon.photos

    if fotos_buscador
      # Para no borrar las anteriores fotos
      fotos_naturalista.each do |photo|
        photo.save
        taxon_photo = TaxonPhoto.new(:especie_id => taxon.id, :photo_id => photo.id)
        taxon_photo.save
      end
    else
      fotos_buscador = fotos_naturalista
      taxon.save
    end
  end

  #Guarda el kml asociado al taxon
  def kml
    return [] unless snib_id.present?
    response = RestClient.get "#{CONFIG.snib_url}&rd=#{snib_reino}&id=#{snib_id}", :timeout => 1000, :open_timeout => 1000
    return [] unless response.present?
    data = JSON.parse(response)
    colectas = data['colectas']
    return [] unless colectas.count > 0
    cadenas = []

    colectas.each do |col|
      datos = col['properties']
      next unless datos['nombrepaismapa'] == 'MEXICO'
      cadena = Hash.new

      #Los numere para poder armar los datos en el orden deseado
      cadena['1_nombre_cientifico'] = especie.nombre_cientifico
      cadena['2_nombre_comun'] = especie.nombre_comun_principal
      cadena['4_nombre_coleccion'] = datos['nombrecoleccion']
      cadena['5_nombre_institucion'] = datos['nombreinstitucion']
      cadena['6_nombre_colector'] = datos['nombrecolector']
      cadena['7_url_proyecto_conabio'] = datos['url_proyecto_conabio']
      cadena['8_longitude'] = datos['longitud']
      cadena['9_latitude'] = datos['latitud']

      #Pone la fecha en formato tiemestamp
      cadena['3_datetime'] = "#{datos['aniocolecta']}-#{datos['mescolecta'].to_s.rjust(2,'0')}-#{datos['diacolecta'].to_s.rjust(2,'0')} 00:00:00"

      cadenas << cadena
    end
    self.snib_kml = to_kml(cadenas)
  end

  #Guarda el kml de naturalista asociado al taxon
  def kml_naturalista
    return [] unless naturalista_obs.present?
    obs = eval(naturalista_obs).first
    return [] unless obs.count > 0
    cadenas = []

    obs.each do |ob|
      next if ob['captive']
      cadena = Hash.new

      #Los numere para poder armar los datos en el orden deseado
      cadena['1_nombre_cientifico'] = especie.nombre_cientifico
      cadena['2_nombre_comun'] = especie.nombre_comun_principal
      cadena['5_observed_on'] = "#{ob['observed_on']} 00:00:00"
      cadena['6_quality_grade'] = ob['quality_grade']
      cadena['7_uri'] = ob['uri']
      cadena['8_longitude'] = ob['longitude']
      cadena['9_latitude'] = ob['latitude']

      ob['photos'].each do |photo|
        cadena['3_thumb_url'] = photo['thumb_url']
        cadena['4_attribution'] = photo['attribution']
        break
      end
      cadenas << cadena
    end
    self.naturalista_kml = to_kml_naturalista(cadenas)
  end

  def kmz
    ruta = Rails.root.join('public', 'kmz', especie.id.to_s)
    FileUtils.mkpath(ruta, :mode => 0755) unless File.exists?(ruta)
    ruta_kml = ruta.join('registros.kml')
    File.open(ruta_kml, 'w+') { |file| file.write(snib_kml) }
    system "zip #{ruta.join('registros')} #{ruta_kml}"
    ruta_zip = ruta.join('registros.zip')
    File.delete(ruta_kml) if File.exists?(ruta_kml)
    rename = File.rename(ruta_zip, ruta.join('registros.kmz'))
    rename == 0
  end

  def kmz_naturalista
    ruta = Rails.root.join('public', 'kmz', especie.id.to_s)
    FileUtils.mkpath(ruta, :mode => 0755) unless File.exists?(ruta)
    ruta_kml = ruta.join('observaciones.kml')
    File.open(ruta_kml, 'w+') { |file| file.write(naturalista_kml) }
    system "zip #{ruta.join('observaciones')} #{ruta_kml}"
    ruta_zip = ruta.join('observaciones.zip')
    File.delete(ruta_kml) if File.exists?(ruta_kml)
    rename = File.rename(ruta_zip, ruta.join('observaciones.kmz'))
    rename == 0
  end

  def info_naturalista
    if naturalista_id.present?
      response = RestClient.get "#{CONFIG.naturalista_url}/taxa/#{naturalista_id}.json"
      data = JSON.parse(response)
    else
      response = RestClient.get "#{CONFIG.naturalista_url}/taxa/search.json?q=#{URI.escape(Limpia.cadena(especie.nombre_cientifico))}"
      data_todos = JSON.parse(response)
      data = Proveedor.comprueba_nombre(especie.nombre_cientifico, data_todos)
    end

    return nil unless data.present?
    self.naturalista_id = data['id']
    self.naturalista_info = "#{data}"     #solo para actualizar el json
    return unless especie.species_or_lower?
    obs_naturalista
  end

  def obs_naturalista
    data = []
    url = "#{CONFIG.naturalista_url}/observations.json?taxon_id=#{naturalista_id}"
    url << "&swlat=#{CONFIG.swlat}&swlng=#{CONFIG.swlng}&nelat=#{CONFIG.nelat}&nelng=#{CONFIG.nelng}&has[]=geo"

    # Loop de maximo 20000 registros para NaturaLista
    for i in 1..100 do
      url << "&page=#{i}&per_page=200"
      rest_client = RestClient.get url
      response_obs = JSON.parse(rest_client)
      break unless response_obs.present?
      i == 1 ? data << response_obs : data + response_obs
      break unless data.count < 200
    end
    self.naturalista_obs = "#{data}" if data.present?
  end

  def self.crea_info_naturalista(taxon)
    response = RestClient.get "#{CONFIG.naturalista_url}/taxa/search.json?q=#{URI.escape(Limpia.cadena(taxon.nombre_cientifico))}"
    data = JSON.parse(response)
    exact_data = Proveedor.comprueba_nombre(taxon.nombre_cientifico, data)

    return nil unless exact_data.present?
    proveedor = Proveedor.new(:especie_id => taxon.id, :naturalista_id => exact_data['id'], :naturalista_info => "#{exact_data}")
    return proveedor unless taxon.species_or_lower?
    proveedor.obs_naturalista
    proveedor
  end

  def self.comprueba_nombre(taxon, data)
    return nil if data.count == 0
    data.each do |d|
      if d['name'] == taxon
        return d
      end
    end
    nil
  end

  private

  def to_kml(cadenas)
    kml = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
    kml << "<kml xmlns=\"http://www.opengis.net/kml/2.2\">\n"
    kml << "<Document>\n"
    kml << "<Style id=\"normalPlacemark\">\n"
    kml << "<IconStyle>\n"
    kml << "<Icon>\n"
    kml << "<href>https://storage.googleapis.com/support-kms-prod/SNP_2752125_en_v0</href>\n"
    kml << "</Icon>\n"
    kml << "</IconStyle>\n"
    kml << "</Style>\n"

    cadenas.each do |cad|
      valor = cad['2_nombre_comun'].present? ? "<b>#{cad['2_nombre_comun']}</b> <i>(#{cad['1_nombre_cientifico']})</i>" : "<i><b>#{cad['1_nombre_cientifico']}</b></i>"
      kml << "<Placemark>\n"
      kml << "<description>\n"
      kml << "<![CDATA[\n"
      kml << "<div>\n"
      kml << "<h4>\n"
      kml << "<a href=\"http://bios.conabio.gob.mx/especies/#{especie.id}\">#{valor}</a>\n"
      kml << "</h4>\n"

      cad.keys.sort.each do |k|
        next unless cad[k].present?

        case k
          when '3_datetime'
            kml << "<p><b>Fecha: </b><text>#{cad[k]}</text></p>\n"
          when '4_nombre_coleccion'
            kml << "<p><b>Colección: </b><text>#{cad[k]}</text></p>\n"
          when '5_nombre_institucion'
            kml << "<p><b>Institución: </b><text>#{cad[k]}</text></p>\n"
          when '6_nombre_colector'
            kml << "<p><b>Nombre del colector: </b><text>#{cad[k]}</text></p>\n"
          when '7_url_proyecto_conabio'
            kml << "<p><text>Enlace al</text> <a href=\"#{cad[k]}\">proyecto</a></p>\n"
          else
            next
        end
      end

      kml << "</div>\n"
      kml << "]]>\n"
      kml << "</description>\n"
      kml << '<styleUrl>#normalPlacemark</styleUrl>'
      kml << "<Point>\n<coordinates>\n#{cad['8_longitude']},#{cad['9_latitude']}\n</coordinates>\n</Point>\n"
      kml << "</Placemark>\n"
    end

    kml << "</Document>\n"
    kml << '</kml>'
  end

  def to_kml_naturalista(cadenas)
    kml = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
    kml << "<kml xmlns=\"http://earth.google.com/kml/2.2\">\n"
    kml << "<Document>\n"

    cadenas.each do |cad|
      kml << "<Placemark>\n"
      kml << "<ExtendedData>\n"

      cad.keys.sort.each do |k|
        next unless cad[k].present?

        case k
          when '1_nombre_cientifico'
            valor = cad['2_nombre_comun'].present? ? "<b>#{cad['2_nombre_comun']}</b> <i>(#{cad[k]})</i>" : "<i>#{cad[k]}</i>"
            kml << "<Data name=\"Especie o grupo\">\n<value>\n#{valor}\n</value>\n</Data>\n"
          when '3_thumb_url'
            kml << "<Data name=\"Observación\">\n<value>\n<img src=\"#{cad[k]}\"/>\n</value>\n</Data>\n"
          when '4_attribution'
            kml << "<Data name=\"Atribución\">\n<value>\n#{cad[k]}\n</value>\n</Data>\n"
          when '5_observed_on'
            kml << "<Data name=\"Fecha\">\n<value>\n#{cad[k]}\n</value>\n</Data>\n"
          when '6_quality_grade'
            kml << "<Data name=\"Grado de calidad\">\n<value>\n#{I18n.t('quality_grade.' << cad[k])}\n</value>\n</Data>\n"
          when '7_uri'
            kml << "<Data name=\"Registro\">\n<value>\nVer la <a href=\"#{cad[k]}\">observación</a>\n</value>\n</Data>\n"
          else
            next
        end
      end

      kml << "</ExtendedData>\n"
      kml << "<Point>\n<coordinates>\n#{cad['8_longitude']},#{cad['9_latitude']}\n</coordinates>\n</Point>\n"
      kml << "</Placemark>\n"
    end

    kml << "</Document>\n"
    kml << '</kml>'
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
