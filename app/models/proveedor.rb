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

    fotos_naturalista= taxon_photos(datos, usuario)
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
    response = RestClient.get "#{CONFIG.snib_url}&rd=#{snib_reino}&id=#{snib_id}"
    return [] unless response.present?
    data = JSON.parse(response)
    colectas = data['colectas']
    return [] unless colectas.count > 0
    cadenas = []

    colectas.each do |col|
      datos = col['properties']
      next unless datos['proceso_val'] == 'MX_validoE'
      cadena = Hash.new

      #Los numere para poder armar los datos en el orden deseado
      cadena['1_nombre_cientifico'] = especie.nombre_cientifico
      cadena['2_nombre_comun'] = especie.nombre_comun_principal
      cadena['4_nombre_coleccion'] = datos['nombrecoleccion']
      cadena['5_nombre_institucion'] = datos['nombreinstitucion']
      cadena['6_pais_coleccion'] = datos['paiscoleccion']
      cadena['7_longitude'] = datos['x_7']
      cadena['8_latitude'] = datos['y_7']

      #Pone la fecha correcta si tiene el formato indicado
      if datos['aniocolecta'] != 9999 && datos['mescolecta'] != 99 && datos['diacolecta'] != 99
        cadena['3_datetime'] = "#{datos['aniocolecta']}-#{datos['mescolecta']}-#{datos['diacolecta']} 00:00:00"
      end

      cadenas << cadena
    end
    self.snib_kml = to_kml(cadenas)
  end

  private

  def to_kml(cadenas)
    kml = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
    kml+= "<kml xmlns=\"http://earth.google.com/kml/2.2\">\n"
    kml+= "<Document>\n"

    cadenas.each do |cad|
      kml+= "<Placemark>\n"
      kml+= "<ExtendedData>\n"

      cad.keys.sort.each do |k|
        next unless cad[k].present?

        case k
          when '1_nombre_cientifico'
            valor = cad['2_nombre_comun'].present? ? "<b>#{cad['2_nombre_comun']}</b> <i>(#{cad[k]})</i>" : "<i>#{cad[k]}</i>"
            kml+= "<Data name=\"#{}\">\n<value>\n#{valor}\n</value>\n</Data>\n"
          when '3_datetime'
            kml+= "<Data name=\"Fecha\">\n<value>\n#{cad[k]}\n</value>\n</Data>\n"
          when '4_nombre_coleccion'
            kml+= "<Data name=\"Colección\">\n<value>\n#{cad[k]}\n</value>\n</Data>\n"
          when '5_nombre_institucion'
            kml+= "<Data name=\"Institución\">\n<value>\n#{cad[k]}\n</value>\n</Data>\n"
          when '6_pais_coleccion'
            kml+= "<Data name=\"País de procedencia\">\n<value>\n#{cad[k]}\n</value>\n</Data>\n"
          else
            next
        end
      end

      kml+= "</ExtendedData>\n"
      kml+= "<Point>\n<coordinates>\n#{cad['7_longitude']},#{cad['8_latitude']}\n</coordinates>\n</Point>\n"
      kml+= "</Placemark>\n"
    end

    kml+= "</Document>\n"
    kml+= '</kml>'
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
