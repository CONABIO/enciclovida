class Proveedor < ActiveRecord::Base

  belongs_to :especie
  attr_accessor :totales, :observaciones, :observacion, :observaciones_mapa, :kml, :ejemplares

  # Las fotos de referencia de naturalista son una copia de las fotos de referencia de enciclovida
  def fotos_naturalista
    ficha = ficha_naturalista_api_nodejs
    return ficha unless ficha[:estatus] == 'OK'

    resultado = ficha[:ficha]['results'].first
    fotos = resultado['taxon_photos']
    {estatus: 'OK', fotos: fotos}
  end

  # Todos los nombres comunes de la ficha de naturalista
  def nombres_comunes_naturalista
    ficha = ficha_naturalista_api
    return ficha unless ficha[:estatus] == 'OK'

    nombres_comunes = ficha[:ficha]['taxon_names']
    # Pone en la primera posicion el deafult_name
    nombres_comunes.unshift(ficha[:ficha]['default_name']) if (ficha[:ficha]['default_name'].present? && ficha[:ficha]['default_name'].any?)
    {estatus: 'OK', nombres_comunes: nombres_comunes}
  end

  # Consulta la fihca de naturalista por medio de su API nodejs
  def ficha_naturalista_api_nodejs
    # Si no existe naturalista_id, trato de buscar el taxon en su API y guardo el ID
    if naturalista_id.blank?
      resp = especie.ficha_naturalista_por_nombre
      return resp unless resp[:estatus] == 'OK'
    end

    begin
      resp = RestClient.get "#{CONFIG.inaturalist_api}/taxa/#{naturalista_id}"
      ficha = JSON.parse(resp)
    rescue => e
      return {estatus: 'error', msg: e}
    end

    return {estatus: 'error', msg: 'Tiene más de un resultado, solo debería ser uno por ser ficha'} unless ficha['total_results'] == 1
    return {estatus: 'OK', ficha: ficha}
  end

  # Consulta la ficha por medio de su API web, algunas cosas no vienen en el API nodejs
  def ficha_naturalista_api
    # Si no existe naturalista_id, trato de buscar el taxon en su API y guardo el ID
    if naturalista_id.blank?
      resp = especie.ficha_naturalista_por_nombre
      return resp unless resp[:estatus] == 'OK'
    end

    begin
      resp = RestClient.get "#{CONFIG.naturalista_url}/taxa/#{naturalista_id}.json"
      ficha = JSON.parse(resp)
    rescue => e
      return {estatus: 'error', msg: e}
    end

    return {estatus: 'error', msg: 'Tiene más de un resultado, solo debería ser uno por ser ficha'} if ficha['error'] == 'No encontrado'
    return {estatus: 'OK', ficha: ficha}
  end

  # Saca los nombres comunes del campo naturalista_info
  def nombres_comunes
    datos = eval(naturalista_info.decodifica64)
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
      nombres_comunes_faltan << "#{especie.catalogo_id},\"#{datos_nombres['name']}\",#{lengua},#{especie.nombre_cientifico},#{especie.categoria_taxonomica.nombre_categoria_taxonomica},#{CONFIG.naturalista_url}/taxa/#{naturalista_id}"
    end

    nombres_comunes_faltan
  end

  def fotos(usuario)
    datos = eval(naturalista_info.decodifica64)
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
            taxon_photo = TaxonPhoto.new(especie_id: taxon.id, photo_id: photo.id)
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

  def usuario_naturalista
    response = RestClient.get "#{CONFIG.naturalista_url}/taxa/search.json?q=#{URI.escape(Limpia.cadena(taxon.nombre_cientifico))}"
    JSON.parse(response)
  end

  def geodatos
    geodatos = {}
    geodatos[:cuales] = []

    if geoserver_info.present?
      info = JSON.parse(geoserver_info)

      geodatos[:cuales] << 'geoserver'
      geodatos[:geoserver_url] = CONFIG.geoserver_url.to_s
      geodatos[:geoserver_descarga_url] = "#{CONFIG.geoserver_descarga_url}&layers=cnb:#{info['layers']}&styles=#{info['styles']}&bbox=#{info['bbox']}&transparent=true"
      geodatos[:geoserver_layer] = info['layers']
    end

    # Para las descargas del SNIB
    carpeta = carpeta_geodatos
    nombre = carpeta.join("ejemplares_#{especie.nombre_cientifico.limpiar.gsub(' ','_')}")
    url = "#{CONFIG.enciclovida_url}/especies/#{especie_id}/ejemplares-snib"

    if File.exists?("#{nombre}.json")
      geodatos[:cuales] << 'snib'
      geodatos[:snib_json] = "#{url}.json"
    end

    if File.exists?("#{nombre}.kml")
      geodatos[:cuales] << 'snib'
      geodatos[:snib_kml] = "#{url}.kml"
    end

    if File.exists?("#{nombre}.kmz")
      geodatos[:cuales] << 'snib'
      geodatos[:snib_kmz] = "#{url}.kmz"
    end

    # Para las descargas de naturalista
    url = "#{CONFIG.enciclovida_url}/especies/#{especie_id}/observaciones-naturalista"

    resp = observaciones_naturalista('.json')
    if resp[:estatus] == 'OK'
      geodatos[:cuales] << 'naturalista'
      geodatos[:naturalista_json] = "#{url}.json"
    end

    resp = observaciones_naturalista('.kml')
    if resp[:estatus] == 'OK'
      geodatos[:cuales] << 'naturalista'
      geodatos[:naturalista_kml] = "#{url}.kml"
    end

    resp = observaciones_naturalista('.kmz')
    if resp[:estatus] == 'OK'
      geodatos[:cuales] << 'naturalista'
      geodatos[:naturalista_kmz] = "#{url}.kmz"
    end

    resp = observaciones_naturalista('.json', true)
    if resp[:estatus] == 'OK'
      geodatos[:cuales] << 'naturalista'
      geodatos[:naturalista_mapa_json] = "#{CONFIG.enciclovida_url}/geodatos/#{especie_id}/#{resp[:ruta].split('/').last}"
    end

    geodatos[:cuales] = geodatos[:cuales].uniq
    geodatos
  end

  # Devuelve la informacion de una sola observacion,  de acuerdo al archivo previamenteguardado del json
  def observacion_naturalista
    resp = observaciones_naturalista('.json')
    return resp unless resp[:estatus] == 'OK'

    resp.merge({observacion: {quality_grade: 'investigacion ;)'}})
  end

  # Devuelve las observaciones de naturalista, ya se en cache de disco o consulta y arma la respuesta para guardarla, la respuesta depende del formato enviado, default es json
  def observaciones_naturalista(formato = '.json', mapa = false)
    carpeta = carpeta_geodatos

    nombre = if mapa
               carpeta.join("observaciones_#{especie.nombre_cientifico.limpiar.gsub(' ','_')}_mapa")
             else
               carpeta.join("observaciones_#{especie.nombre_cientifico.limpiar.gsub(' ','_')}")
             end

    archivo = "#{nombre}#{formato}"

    if File.exist?(archivo)
      {estatus: 'OK', ruta: archivo}
    else
      {estatus: 'error', msg: 'No hay observaciones'}
    end
  end

  def guarda_observaciones_naturalista
    # Para no generar geodatos arriba de familia
    return unless especie.apta_con_geodatos?

    # Para no guardar nada si el cache aun esta vigente
    return if especie.existe_cache?('observaciones_naturalista')

    # Pone el cache para no volverlo a consultar
    especie.escribe_cache('observaciones_naturalista', 1.week) if Rails.env.production?

    # Si no existe naturalista_id, trato de buscar el taxon en su API y guardo el ID
    if naturalista_id.blank?
      resp = especie.ficha_naturalista_por_nombre
      return resp unless resp[:estatus] == 'OK'
    end

    # Valida el paginado y los resultados
    self.observaciones = []
    self.observaciones_mapa = []
    validacion = valida_observaciones_naturalista
    return validacion unless validacion[:estatus] == 'OK'

    # Para el paginado
    paginas = totales/CONFIG.inaturalist_por_pagina.to_i
    residuo = totales%200
    paginas+= 1 if residuo < 200 || paginas == 0

    # Si son mas de 50 paginas, entonces el elastic search truena del lado de inaturalist, ver como resolver despues (pasa mas en familia)
    #return {estatus: 'error', msg: 'Son mas de 50 paginas, truena el elastic search'} if paginas > 50

    if paginas > 1
      # Para consultar las demas paginas, si es que tiene mas de una
      for i in 2..paginas do
        validacion = valida_observaciones_naturalista({page: i})
        return validacion unless validacion[:estatus] == 'OK'
        break if i == 50
      end
    end

    # Crea carpeta y archivo
    carpeta = carpeta_geodatos
    nombre = carpeta.join("observaciones_#{especie.nombre_cientifico.limpiar.gsub(' ','_')}")
    archivo_observaciones = File.new("#{nombre}.json", 'w+')
    archivo_observaciones_mapa = File.new("#{nombre}_mapa.json", 'w+')
    archivo_observaciones_kml = File.new("#{nombre}.kml", 'w+')

    # Guarda el archivo en kml y kmz
    archivo_observaciones.puts observaciones.to_json
    archivo_observaciones_mapa.puts observaciones_mapa.to_json
    archivo_observaciones_kml.puts kml

    # Cierra los archivos
    archivo_observaciones.close
    archivo_observaciones_mapa.close
    archivo_observaciones_kml.close

    # Guarda el archivo en kmz
    kmz(nombre)

    puts "\n\nGuardo observaciones de naturalista #{especie_id}"
  end

  # Devuelve los ejemplares del snib en diferentes formatos, json (default), kml y kmz
  def ejemplares_snib(formato = '.json')
    carpeta = carpeta_geodatos
    nombre = carpeta.join("ejemplares_#{especie.nombre_cientifico.limpiar.gsub(' ','_')}")
    archivo = "#{nombre}#{formato}"

    if File.exist?(archivo)
      {estatus: 'OK', ruta: archivo}
    else
      {estatus: 'error', msg: 'No hay ejemplares en el SNIB'}
    end
  end

  def guarda_ejemplares_snib
    # Para no generar geodatos arriba de familia
    return unless especie.apta_con_geodatos?

    # Para no guardar nada si el cache aun esta vigente
    return if especie.existe_cache?('ejemplares_snib')

    # Pone el cache para no volverlo a consultar
    especie.escribe_cache('ejemplares_snib', 1.day) if Rails.env.production?

    self.ejemplares = []
    validacion = valida_ejemplares_snib
    return validacion unless validacion[:estatus] == 'OK'

    # Crea carpeta y archivo
    carpeta = carpeta_geodatos
    nombre = carpeta.join("ejemplares_#{especie.nombre_cientifico.limpiar.gsub(' ','_')}")
    archivo_ejemplares = File.new("#{nombre}.json", 'w+')
    archivo_ejemplares_kml = File.new("#{nombre}.kml", 'w+')

    # Guarda el archivo en kml y kmz
    archivo_ejemplares.puts self.ejemplares.to_json.gsub('\\', '').gsub('"{', '{').gsub('}"', '}')
    archivo_ejemplares_kml.puts kml

    # Cierra los archivos
    archivo_ejemplares.close
    archivo_ejemplares_kml.close

    # Guarda el archivo en kmz
    kmz(nombre)

    puts "\n\nGuardo ejemplares del snib #{especie_id}"
  end


  private

  # Crea o devuleve la capreta de los geodatos
  def carpeta_geodatos
    carpeta = Rails.root.join('public', 'geodatos', especie_id.to_s)
    FileUtils.mkpath(carpeta, :mode => 0755) unless File.exists?(carpeta)
    carpeta
  end

  # Solo los campos que ocupo en el mapa para no hacer muy grande la respuesta
  def limpia_observaciones_naturalista
    obs = Hash.new
    h = HTMLEntities.new  # Para codificar el html y no marque error en el KML

    # Los numere para poder armar los datos en el orden deseado
    obs[:id] = observacion['id']
    obs[:place_guess] = h.encode(observacion['place_guess'])
    obs[:observed_on] = observacion['observed_on'].gsub('-','/') if observacion['observed_on'].present?
    obs[:captive] =  observacion['captive'] ? 'Organismo silvestre / naturalizado' : nil
    obs[:quality_grade] = I18n.t("quality_grade.#{observacion['quality_grade']}", default: observacion[:quality_grade])
    obs[:uri] = observacion['uri']

    if obs[:uri].present?
      obs[:uri] = obs[:uri].gsub('inaturalist.org','naturalista.mx').gsub('conabio.inaturalist.org', 'www.naturalista.mx').gsub('naturewatch.org.nz', 'naturalista.mx').gsub('conabio.naturalista.mx', 'naturalista.mx')
    end

    obs[:longitude] = observacion['geojson']['coordinates'][0]
    obs[:latitude] = observacion['geojson']['coordinates'][1]

    observacion['photos'].each do |photo|
      obs[:thumb_url] = photo['url']
      obs[:attribution] = h.encode(photo['attribution'])
      break  # Guardo la primera foto
    end

    # Pone la observacion y las observaciones en el arreglo
    self.observacion = obs
    self.observaciones << observacion

    # Pone solo las coordenadas y el ID para el json del mapa, se necesita que sea mas ligero.
    self.observaciones_mapa << [obs[:longitude].to_f, obs[:latitude].to_f, obs[:id], observacion['quality_grade'] == 'research' ? 1 : 0]
  end

  def valida_observaciones_naturalista(params = {})
    page = params[:page] || 1

    begin
      rest_client = RestClient::Request.execute(method: :get, url: "#{CONFIG.inaturalist_api}/observations?taxon_id=#{naturalista_id}&geo=true&&per_page=#{CONFIG.inaturalist_por_pagina}&page=#{page}", timeout: 10)
      res = JSON.parse(rest_client)
    rescue => e
      return {estatus: 'error', msg: e}
    end

    return {estatus: 'error', msg: 'La respuesta del servicio esta vacia'} unless res.any?

    self.totales = res['total_results'] if params.blank? && totales.blank?  # Para la primera pagina de naturalista
    resultados = res['results'] if res['results'].any?

    return {estatus: 'error', msg: 'No hay observaciones'} if totales.blank? || (totales.present? && totales <= 0)
    return {estatus: 'error', msg: 'No hay observaciones'} if resultados.blank? || resultados.count == 0

    # Limpia las observaciones y  las transforma a kml
    kml_naturalista(inicio: true)

    resultados.each do |observacion|
      self.observacion = observacion
      limpia_observaciones_naturalista
      kml_naturalista(observacion: true)
    end

    kml_naturalista(fin: true)

    {estatus: 'OK'}
  end

  def kml_naturalista(opc = {})

    if opc[:inicio]
      self.kml = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
      self.kml << "<kml xmlns=\"http://www.opengis.net/kml/2.2\">\n"
      self.kml << "<Document>\n"

      # Para las observaciones de grado cientifico, verde
      self.kml << "<Style id=\"Placemark_cientifico\">\n"
      self.kml << "<IconStyle>\n"
      self.kml << "<Icon>\n"
      self.kml << "<href>#{CONFIG.enciclovida_url}/assets/app/placemarks/verde.png</href>\n"
      self.kml << "</Icon>\n"
      self.kml << "</IconStyle>\n"
      self.kml << "</Style>\n"

      # Para las observaciones de grado casual, amarillo
      self.kml << "<Style id=\"Placemark_casual\">\n"
      self.kml << "<IconStyle>\n"
      self.kml << "<Icon>\n"
      self.kml << "<href>#{CONFIG.enciclovida_url}/assets/app/placemarks/amarillo.png</href>\n"
      self.kml << "</Icon>\n"
      self.kml << "</IconStyle>\n"
      self.kml << "</Style>\n"
    end

    if opc[:observacion]
      h = HTMLEntities.new  # Para codificar el html y no marque error en el KML
      nombre_cientifico = h.encode(especie.nombre_cientifico)
      nombre_comun = h.encode(especie.nom_com_prin(true))
      nombre = nombre_comun.present? ? "<b>#{nombre_comun}</b> <i>(#{nombre_cientifico})</i>" : "<i><b>#{nombre_cientifico}</b></i>"

      self.kml << "<Placemark>\n"
      self.kml << "<description>\n"
      self.kml << "<![CDATA[\n"
      self.kml << "<div>\n"
      self.kml << "<h4>\n"
      self.kml << "<a href=\"#{CONFIG.enciclovida_url}/especies/#{especie.id}\">#{nombre}</a>\n"
      self.kml << "</h4>\n"

      self.kml << "<div><img src=\"#{observacion[:thumb_url]}\"/></div>\n"

      self.kml << '<dl>'
      self.kml << "<dt>Atribución</dt> <dd>#{observacion[:attribution]}</dd>\n"
      self.kml << "<dt>Ubicación</dt> <dd>#{observacion[:place_guess]}</dd>\n"
      self.kml << "<dt>Fecha</dt> <dd>#{observacion[:observed_on]}</dd>\n"
      self.kml << "<dt>#{observacion[:captive]}</dt> <dd> </dd>\n"
      self.kml << "<dt>Grado de calidad</dt> <dd>#{observacion[:quality_grade]}</dd>\n"
      self.kml << '</dl>'

      self.kml << "<span><text>Ver la </text><a href=\"#{observacion[:uri]}\">observación en NaturaLista</a></span>\n"

      self.kml << "</div>\n"
      self.kml << "]]>\n"
      self.kml << "</description>\n"

      if observacion[:quality_grade] == 'research'
        self.kml << '<styleUrl>#Placemark_cientifico</styleUrl>'
      else
        self.kml << '<styleUrl>#Placemark_casual</styleUrl>'
      end

      self.kml << "<Point>\n<coordinates>\n#{observacion[:longitude]},#{observacion[:latitude]}\n</coordinates>\n</Point>\n"
      self.kml << "</Placemark>\n"
    end

    if opc[:fin]
      self.kml << "</Document>\n"
      self.kml << '</kml>'
    end
  end

  def kmz(nombre)
    archvo_zip = "#{nombre}.zip"
    system "zip -j #{archvo_zip} #{nombre}.kml"
    File.rename(archvo_zip, "#{nombre}.kmz")
  end

  def valida_ejemplares_snib
    begin
      rest_client = RestClient::Request.execute(method: :get, url: "#{CONFIG.geoportal_url}&rd=#{especie.root.nombre_cientifico.downcase}&id=#{especie.catalogo_id}", timeout: 3)
      resultados = JSON.parse(rest_client)
    rescue => e
      return {estatus: 'error', msg: e}
    end

    return {estatus: 'error', msg: 'La respuesta del servicio esta vacia'} unless resultados.present?
    self.totales = resultados.count if totales.blank?  # Para la primera pagina de naturalista
    return {estatus: 'error', msg: 'No hay ejemplares'} if totales.blank? || (totales.present? && totales <= 0)

    # ASigna los ejemplares
    self.ejemplares = resultados

    # Exporta a kml los ejemplares
    kml_snib

    {estatus: 'OK'}
  end

  def kml_snib
    h = HTMLEntities.new  # Para codificar el html y no marque error en el KML
    nombre_cientifico = h.encode(especie.nombre_cientifico)
    nombre_comun = h.encode(especie.nom_com_prin(true))
    nombre = nombre_comun.present? ? "<b>#{nombre_comun}</b> <i>(#{nombre_cientifico})</i>" : "<i><b>#{nombre_cientifico}</b></i>"

    self.kml = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
    self.kml << "<kml xmlns=\"http://www.opengis.net/kml/2.2\">\n"
    self.kml << "<Document>\n"
    self.kml << "<Style id=\"normalPlacemark\">\n"
    self.kml << "<IconStyle>\n"
    self.kml << "<Icon>\n"
    self.kml << "<href>#{CONFIG.enciclovida_url}/assets/app/placemarks/rojo.png</href>\n"
    self.kml << "</Icon>\n"
    self.kml << "</IconStyle>\n"
    self.kml << "</Style>\n"

    ejemplares.each do |ejemplar|
      self.kml << "<Placemark>\n"
      self.kml << "<description>\n"
      self.kml << "<![CDATA[\n"
      self.kml << "<div>\n"
      self.kml << "<h4>\n"
      self.kml << "<a href=\"#{CONFIG.enciclovida_url}/especies/#{especie.id}\">#{nombre}</a>\n"
      self.kml << "</h4>\n"
      self.kml << "<dl>\n"

      self.kml << "<dt>Localidad</dt> <dd>#{ejemplar['localidad']}</dd>\n"
      self.kml << "<dt>Municipio</dt> <dd>#{ejemplar['municipiomapa']}</dd>\n"
      self.kml << "<dt>Estado</dt> <dd>#{ejemplar['estadomapa']}</dd>\n"
      self.kml << "<dt>País</dt> <dd>#{ejemplar['paismapa']}</dd>\n"
      self.kml << "<dt>Fecha</dt> <dd>#{ejemplar['fechacolecta']}</dd>\n"
      self.kml << "<dt>Nombre del colector</dt> <dd>#{ejemplar['colector']}</dd>\n"
      self.kml << "<dt>Colección</dt> <dd>#{ejemplar['coleccion']}</dd>\n"
      self.kml << "<dt>Institución</dt> <dd>#{ejemplar['institucion']}</dd>\n"
      self.kml << "<dt>País de la colección</dt> <dd>#{ejemplar['paiscoleccion']}</dd>\n"

      if ejemplar['proyectourl'].present?
        self.kml << "<dt>Proyecto:</dt> <dd><a href=\"#{ejemplar['proyectourl']}\">#{ejemplar['proyecto'] || 'ver'}</a></dd>\n"
      else
        self.kml << "<dt>Proyecto:</dt> <dd>#{ejemplar['proyecto']}</dd>\n"
      end

      self.kml << "</dl>\n"

      self.kml << "<span><text>Más información: </text><a href=\"http://#{ejemplar['urlejemplar']}\">consultar SNIB</a></span>\n"

      self.kml << "</div>\n"
      self.kml << "]]>\n"
      self.kml << "</description>\n"
      self.kml << '<styleUrl>#normalPlacemark</styleUrl>'
      self.kml << "<Point>\n<coordinates>\n#{ejemplar['longitud']},#{ejemplar['latitud']}\n</coordinates>\n</Point>\n"
      self.kml << "</Placemark>\n"
    end

    self.kml << "</Document>\n"
    self.kml << '</kml>'
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
