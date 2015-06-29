class Proveedor < ActiveRecord::Base
  belongs_to :especie
  attr_accessor :snib_kml, :naturalista_kml

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
      nombres_comunes_faltan << "#{especie.catalogo_id},\"#{datos_nombres['name']}\",#{lengua},#{especie.nombre_cientifico},#{especie.categoria_taxonomica.nombre_categoria_taxonomica},http://naturalista.conabio.gob.mx/taxa/#{naturalista_id}"
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

    begin
      fotos_buscador = taxon.photos
    rescue
      puts 'ERROR: Especie no existe'
      return []
    end

    if fotos_buscador
      # Para no borrar las anteriores fotos
      fotos_naturalista.each do |photo|
        if photo.new_record?
          if photo.save
            taxon_photo = TaxonPhoto.new(:especie_id => taxon.id, :photo_id => photo.id)
            taxon_photo.save
          end
        elsif photo.changed?
          photo.save
        end
      end
    else  # Guarda todas las fotos asociadas al taxon
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

      # Para registros solo de Mexico
      #next unless datos['nombrepaismapa'] == 'MEXICO'

      cadena = Hash.new
      h = HTMLEntities.new  # Para codificar el html y no marque error en el KML

      # Los numere para poder armar los datos en el orden deseado
      cadena['01_nombre_cientifico'] = h.encode(especie.nombre_cientifico)
      cadena['02_nombre_comun'] = h.encode(especie.nom_com_prin(true))
      cadena['03_localidad'] = h.encode(datos['localidad'])
      cadena['04_municipio'] = h.encode(datos['nombremunicipiomapa'])
      cadena['05_estado'] = h.encode(datos['nombreestadomapa'])
      cadena['06_pais'] = h.encode(datos['nombrepaismapa'])

      # Para que no se vea feo MEXICO con mayusculas
      if cadena['06_pais'] == 'MEXICO'
        cadena['06_pais'] = 'México'
      end

      # Pone la fecha en formato tiemestamp
      if datos['diacolecta'].to_s == '99'
        datos['diacolecta'] = '??'
      end
      if datos['mescolecta'].to_s == '99'
        datos['mescolecta'] = '??'
      end
      if datos['aniocolecta'].to_s == '9999'
        datos['aniocolecta'] = '????'
      end

      cadena['07_datetime'] = "#{datos['diacolecta'].to_s.rjust(2,'0')}/#{datos['mescolecta'].to_s.rjust(2,'0')}/#{datos['aniocolecta']}"

      cadena['08_nombre_colector'] = h.encode(datos['nombrecolector'])
      cadena['09_nombre_coleccion'] = h.encode(datos['nombrecoleccion'])
      cadena['10_nombre_institucion'] = h.encode(datos['nombreinstitucion'])
      cadena['11_siglas_institucion'] = h.encode(datos['siglasinstitucion'])
      cadena['12_pais_coleccion'] = h.encode(datos['paiscoleccion'])

      cadena['13_longitude'] = datos['longitud']
      cadena['14_latitude'] = datos['latitud']

      cadenas << cadena
    end
    self.snib_kml = to_kml(cadenas)
  end

  # Guarda el kml de naturalista asociado al taxon
  def kml_naturalista
    return [] unless naturalista_obs.present?
    obs = eval(naturalista_obs).first
    return [] unless obs.count > 0
    cadenas = []

    obs.each do |ob|
      # Para evitar las captivas
      #next if ob['captive']

      cadena = Hash.new

      # Los numere para poder armar los datos en el orden deseado
      cadena['01_nombre_cientifico'] = h.encode(especie.nombre_cientifico)
      cadena['02_nombre_comun'] = h.encode(especie.nom_com_prin(true))
      cadena['05_place_guess'] = h.encode(ob['place_guess'])
      cadena['06_observed_on'] = ob['observed_on'].gsub('-','/') if ob['observed_on'].present?
      cadena['07_captive'] =  ob['captive'] ? 'Organismo silvestre / naturalizado' : nil
      cadena['08_quality_grade'] = ob['quality_grade']
      cadena['09_uri'] = ob['uri']

      if cadena['09_uri'].present?
        cadena['09_uri'] = cadena['09_uri'].gsub('www.inaturalist.org','naturalista.conabio.gob.mx').gsub('conabio.inaturalist.org', 'naturalista.conabio.gob.mx')
      end

      cadena['10_longitude'] = ob['longitude']
      cadena['11_latitude'] = ob['latitude']

      ob['photos'].each do |photo|
        cadena['03_thumb_url'] = photo['thumb_url']
        cadena['04_attribution'] = h.encode(photo['attribution'])
        break
      end
      cadenas << cadena
    end
    self.naturalista_kml = to_kml_naturalista(cadenas)
  end

  def usuario_naturalista
    response = RestClient.get "#{CONFIG.naturalista_url}/taxa/search.json?q=#{URI.escape(Limpia.cadena(taxon.nombre_cientifico))}"
    data = JSON.parse(response)
  end

  def kmz
    ruta = Rails.root.join('public', 'kmz', especie.id.to_s)
    FileUtils.mkpath(ruta, :mode => 0755) unless File.exists?(ruta)
    ruta_kml = ruta.join('registros.kml')
    File.open(ruta_kml, 'w+') { |file| file.write(snib_kml) }
    system "zip #{ruta.join('registros')} #{ruta_kml}"
    ruta_zip = ruta.join('registros.zip')
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
    rename = File.rename(ruta_zip, ruta.join('observaciones.kmz'))
    rename == 0
  end

  def info_naturalista
    if naturalista_id.present?
      response = RestClient.get "#{CONFIG.naturalista_url}/taxa/#{naturalista_id}.json"
      data = JSON.parse(response)
    else
      response = RestClient.get "#{CONFIG.naturalista_url}/taxa/search.json?q=#{URI.escape(especie.nombre_cientifico.limpiar.limpia)}"
      data_todos = JSON.parse(response)
      data = Proveedor.comprueba_nombre(especie.nombre_cientifico, data_todos)
    end

    return nil unless data.present?
    self.naturalista_id = data['id']
    self.naturalista_info = "#{data}"     #solo para actualizar el json

    # Solo para especies o inferiores
    return unless especie.species_or_lower?
    obs_naturalista
  end

  def obs_naturalista
    data = []
    url = "#{CONFIG.naturalista_url}/observations.json?taxon_id=#{naturalista_id}&has[]=geo"
    # Para limitarlo solo al cuadrado de la republica
    #url << "&swlat=#{CONFIG.swlat}&swlng=#{CONFIG.swlng}&nelat=#{CONFIG.nelat}&nelng=#{CONFIG.nelng}"

    # Loop de maximo 200,000 registros para NaturaLista (suficientes)
    for i in 1..1000 do
      url << "&page=#{i}&per_page=200"
      rest_client = RestClient.get url
      response_obs = JSON.parse(rest_client)
      break unless response_obs.present?
      i == 1 ? data << response_obs : data + response_obs
      break if i > 1000
    end
    self.naturalista_obs = "#{data}" if data.present?
  end

  def geodatos
    ruta_snib_kmz = Rails.root.join('public', 'kmz', especie.id.to_s, 'registros.kmz')
    ruta_snib_kml = Rails.root.join('public', 'kmz', especie.id.to_s, 'registros.kml')
    ruta_naturalista_kmz = Rails.root.join('public', 'kmz', especie.id.to_s, 'observaciones.kmz')
    ruta_naturalista_kml = Rails.root.join('public', 'kmz', especie.id.to_s, 'observaciones.kml')

    rutas = Hash.new
    ruta_absoluta = "#{CONFIG.servidor}/#{especie.id.to_s}"
    rutas[:snib_kml] = "#{ruta_absoluta}/registros.kml" if File.exist?(ruta_snib_kml)
    rutas[:snib_kmz] = "#{ruta_absoluta}/registros.kmz" if File.exist?(ruta_snib_kmz)
    rutas[:naturalista_kml] = "#{ruta_absoluta}/observaciones.kml" if File.exist?(ruta_naturalista_kml)
    rutas[:naturalista_kmz] = "#{ruta_absoluta}/observaciones.kmz" if File.exist?(ruta_naturalista_kmz)

    if geoserver_info.present?
      info = JSON.parse(geoserver_info)
      rutas[:geoserver_kmz] = "#{CONFIG.geoserver_url}&layers=cnb:#{info['layers']}&styles=#{info['styles']}&bbox=#{info['bbox']}"
    end

    rutas.to_json
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
    evitar_campos = ['99/99/9999','??/??/????', 'NO DISPONIBLE', 'SIN INFORMACION', 'NA NA NA', 'ND ND ND', 'NO APLICA']

    kml = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
    kml << "<kml xmlns=\"http://www.opengis.net/kml/2.2\">\n"
    kml << "<Document>\n"
    kml << "<Style id=\"normalPlacemark\">\n"
    kml << "<IconStyle>\n"
    kml << "<Icon>\n"
    kml << "<href>http://bios.conabio.gob.mx/assets/app/placemarks/rojo.png</href>\n"
    kml << "</Icon>\n"
    kml << "</IconStyle>\n"
    kml << "</Style>\n"

    cadenas.each do |cad|
      nombre = cad['02_nombre_comun'].present? ? "<b>#{cad['02_nombre_comun']}</b> <i>(#{cad['01_nombre_cientifico']})</i>" : "<i><b>#{cad['01_nombre_cientifico']}</b></i>"
      kml << "<Placemark>\n"
      kml << "<description>\n"
      kml << "<![CDATA[\n"
      kml << "<div>\n"
      kml << "<h4>\n"
      kml << "<a href=\"http://bios.conabio.gob.mx/especies/#{especie.id}\">#{nombre}</a>\n"
      kml << "</h4>\n"
      kml << "<dl>\n"

      cad.keys.sort.each do |k|
        next unless cad[k].present?
        next if evitar_campos.include? cad[k]

        case k
          when '03_localidad'
            kml << "<dt>Localidad</dt> <dd>#{cad[k]}</dd>\n"
          when '04_municipio'
            kml << "<dt>Municipio</dt> <dd>#{cad[k]}</dd>\n"
          when '05_estado'
            kml << "<dt>Estado</dt> <dd>#{cad[k]}</dd>\n"
          when '06_pais'
            kml << "<dt>País</dt> <dd>#{cad[k]}</dd>\n"
          when '07_datetime'
            kml << "<dt>Fecha</dt> <dd>#{cad[k]}</dd>\n"
          when '08_nombre_colector'
            kml << "<dt>Nombre del colector</dt> <dd>#{cad[k]}</dd>\n"
          when '09_nombre_coleccion'
            kml << "<dt>Colección</dt> <dd>#{cad[k]}</dd>\n"
          when '10_nombre_institucion'
            kml << "<dt>Institución</dt> <dd>#{cad[k]}</dd>\n"
          when '11_siglas_institucion'
            kml << "<dt>Siglas de la institución</dt> <dd>#{cad[k]}</dd>\n"
          when '12_pais_coleccion'
            kml << "<dt>País de la colección</dt> <dd>#{cad[k]}</dd>\n"
          else
            next
        end
      end

      kml << "</dl>\n"
      kml << "</div>\n"
      kml << "]]>\n"
      kml << "</description>\n"
      kml << '<styleUrl>#normalPlacemark</styleUrl>'
      kml << "<Point>\n<coordinates>\n#{cad['13_longitude']},#{cad['14_latitude']}\n</coordinates>\n</Point>\n"
      kml << "</Placemark>\n"
    end

    kml << "</Document>\n"
    kml << '</kml>'
  end

  def to_kml_naturalista(cadenas)
    kml = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
    kml << "<kml xmlns=\"http://www.opengis.net/kml/2.2\">\n"
    kml << "<Document>\n"

    # Para las observaciones de grado cientifico, verde
    kml << "<Style id=\"Placemark_cientifico\">\n"
    kml << "<IconStyle>\n"
    kml << "<Icon>\n"
    kml << "<href>http://bios.conabio.gob.mx/assets/app/placemarks/verde.png</href>\n"
    kml << "</Icon>\n"
    kml << "</IconStyle>\n"
    kml << "</Style>\n"

    # Para las observaciones de grado casual, amarillo
    kml << "<Style id=\"Placemark_casual\">\n"
    kml << "<IconStyle>\n"
    kml << "<Icon>\n"
    kml << "<href>http://bios.conabio.gob.mx/assets/app/placemarks/amarillo.png</href>\n"
    kml << "</Icon>\n"
    kml << "</IconStyle>\n"
    kml << "</Style>\n"

    cadenas.each do |cad|
      grado = ''
      foto = ''
      enlace = ''
      campos = ''
      valor = cad['02_nombre_comun'].present? ? "<b>#{cad['02_nombre_comun']}</b> <i>(#{cad['01_nombre_cientifico']})</i>" : "<i><b>#{cad['01_nombre_cientifico']}</b></i>"
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
          when '03_thumb_url'
            foto << "<div><img src=\"#{cad[k]}\"/></div>\n"
          when '04_attribution'
            campos << "<dt>Atribución</dt> <dd>#{cad[k]}</dd>\n"
          when '05_place_guess'
            campos << "<dt>Ubicación</dt> <dd>#{cad[k]}</dd>\n"
          when '06_observed_on'
            campos << "<dt>Fecha</dt> <dd>#{cad[k]}</dd>\n"
          when '07_captive'
            campos << "<dt>#{cad[k]}</dt> <dd> </dd\n"
          when '08_quality_grade'
            campos << "<dt>Grado de calidad</dt> <dd>#{I18n.t('quality_grade.' << cad[k])}</dd>\n"
            grado = cad[k]
          when '09_uri'
            enlace << "<span><text>Ver la </text><a href=\"#{cad[k]}\">observación en NaturaLista</a></span>\n"
          else
            next
        end
      end

      kml << foto << '<dl>' << campos << '</dl>' << enlace << "\n"
      kml << "</div>\n"
      kml << "]]>\n"
      kml << "</description>\n"

      if grado == 'research'
        kml << '<styleUrl>#Placemark_cientifico</styleUrl>'
      else
        kml << '<styleUrl>#Placemark_casual</styleUrl>'
      end

      kml << "<Point>\n<coordinates>\n#{cad['10_longitude']},#{cad['11_latitude']}\n</coordinates>\n</Point>\n"
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
