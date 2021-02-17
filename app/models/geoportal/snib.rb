class Geoportal::Snib < GeoportalAbs

  self.table_name = 'snib'

  attr_accessor :resp, :params, :campo_tipo_region
  attr_accessor :registros, :kml

  COLECCION_NATURALISTA = [5]
  COLECCION_SNIB = [1,2,3,4]

  # Regresa todas las especies que coincidan con el tipo de region y id seleccionado
  def especies
    tipo_region_a_llave_foranea

    self.resp = Rails.cache.fetch("br_#{params[:tipo_region]}_#{params[:region_id]}", expires_in: eval(CONFIG.cache.busquedas_region)) do
      consulta_especies_por_region
    end
  end

  # Borra el cache de las especies por region
  def borra_cache_especies
    Rails.cache.delete("br_#{params[:tipo_region]}_#{params[:region_id]}") if Rails.cache.exist?("br_#{params[:tipo_region]}_#{params[:region_id]}")
  end

  # Regresa todos los ejemplares que coincidan con el tipo de region,region id y idcat
  def ejemplares
    tipo_region_a_llave_foranea
    
    # Hace el query en vivo, ya que es una cantidad relativamente pequeña de ejemplares
    if campo_tipo_region.present? && params[:region_id].present? 
      self.resp = consulta_ejemplares_por_region
    else  # Lo guarda en cache
      self.resp = Rails.cache.fetch("br_#{params[:catalogo_id]}_#{params[:tipo_region]}_#{params[:region_id]}", expires_in: eval(CONFIG.cache.busquedas_region)) do
        consulta_ejemplares_por_region
      end
    end
  end

  # Regresa la información asociada a un ejemplar por medio de su ID
  def ejemplar
    if params[:ejemplar_id].present?
      if ejemplar = Geoportal::Snib.where(id: params[:ejemplar_id]).first
        self.resp = { estatus: true, resultados: [ejemplar] }
      else
        self.resp = { estatus: false, msg: 'No se encontro información con el ID proporcionado' }
      end
    end
  end
  
  # Actualiza el idnombrecatvalido de las infraespecies para cambiarlo por su especie correspondiente y asigna la especie valida de acuerdo a catalogocentralizado
  def self.actualiza_idnombrecatvalido
    ids = Geoportal::Snib.all.select(:idnombrecatvalido).group(:idnombrecatvalido).map(&:idnombrecatvalido)
    ids_count = ids.length
    Rails.logger.debug "Taxones a correr: #{ids_count}"

    ids.each_with_index do |catalogo_id, index|
      Rails.logger.debug "Index: #{index+1} de #{ids_count}"
      next unless scat = Scat.where(catalogo_id: catalogo_id).first
      next unless t = scat.especie
      infraespecies = %w(subespecie variedad raza forma)

      if infraespecies.include?(t.categoria_taxonomica.nombre_categoria_taxonomica)
        next unless especie = Especie.joins(:categoria_taxonomica).where(id: t.ancestry_ascendente_obligatorio.split(',').reject { |c| c.empty? }).
        where("#{CategoriaTaxonomica.attribute_alias(:nombre_categoria_taxonomica)}='especie'").first
        especie = especie.dame_taxon_valido
      else
        next if t.estatus == 2
        especie = t.dame_taxon_valido
      end
      
      next unless especie
      next unless scat = especie.scat
      Rails.logger.debug "Original: #{catalogo_id} ---> #{scat.catalogo_id}"
      Geoportal::Snib.where(idnombrecatvalido: catalogo_id).update_all(idnombrecatvalido: scat.catalogo_id)

    end
  end

  # Guarda el archivo debajo de geodata para un posterior uso, se puede consumir al vuelo a la hora de generarlos
  def guarda_registros
    valida_registros
    return resp unless resp[:estatus]
    equivalencias = { 'naturalista' => { tipo_coleccion: COLECCION_SNIB, archivo: 'observaciones-naturalista-' }, 'snib' => { tipo_coleccion: COLECCION_NATURALISTA, archivo: 'ejemplares-snib-' }}
    tipo_coleccion = equivalencias[params[:coleccion]][:tipo_coleccion]

    case params[:coleccion]
    when 'naturalista', 'snib'
      colecciones = Rails.cache.fetch("br_#{params[:catalogo_id]}__")[:resultados].try(:keys)
      return self.resp = { estatus: false, msg: "No tiene registros en el cache: br_#{params[:catalogo_id]}__" } unless (colecciones & tipo_coleccion).any?

      case params[:formato]
      when 'json'
        self.registros = Geoportal::Snib.where(idnombrecatvalido: params[:catalogo_id], tipocoleccion: tipo_coleccion)
        carpeta = carpeta_geodatos
        nombre = carpeta.join("#{equivalencias[params[:coleccion]][:archivo]}#{params[:taxon].nombre_cientifico.estandariza}")
        
        archivo = File.new("#{nombre}.#{params[:formato]}", 'w+')
        archivo.puts registros.to_json
        archivo.close
        self.resp = { estatus: true, archivo: archivo }
      when 'kml'
        self.registros = Geoportal::Snib.where(idnombrecatvalido: params[:catalogo_id], tipocoleccion: tipo_coleccion)
        carpeta = carpeta_geodatos
        nombre = carpeta.join("#{equivalencias[params[:coleccion]][:archivo]}#{params[:taxon].nombre_cientifico.estandariza}")
        
        archivo = File.new("#{nombre}.#{params[:formato]}", 'w+')
        to_kml
        archivo.puts kml
        archivo.close
        self.resp = { estatus: true, archivo: archivo }
      when 'kmz'
        self.registros = Geoportal::Snib.where(idnombrecatvalido: params[:catalogo_id], tipocoleccion: tipo_coleccion)
        carpeta = carpeta_geodatos
        nombre = carpeta.join("#{equivalencias[params[:coleccion]][:archivo]}#{params[:taxon].nombre_cientifico.estandariza}")
        
        if !File.exist?("#{nombre}.kml")
          archivo = File.new("#{nombre}.kml", 'w+')
          to_kml
          archivo.puts kml
          archivo.close
        end

        kmz(nombre)
        self.resp = { estatus: true, ruta: "#{nombre}.#{params[:formato]}" }
      when 'mapa-app'
        self.registros = []
        
        (colecciones & tipo_coleccion).each do |col|
          self.registros << Rails.cache.fetch("br_#{params[:catalogo_id]}__")[:resultados][col]
        end
        
        return self.resp = { estatus: true, registros: registros.flatten(1) }
      else
        return self.resp = { estatus: false, msg: "No tiene el formato correcto de descarga" }
      end

    else
      return self.resp = { estatus: false, msg: 'Opción inválida del tipo de registro' }
    end

    Rails.logger.debug "Guardo ejempalres con catalogo_id: #{params[:catalogo_id]}, colección: #{params[:coleccion]}"
  end

  def tiene_registros?
    valida_registros
    return unless resp[:estatus]
    return self.resp = { estatus: true } unless params[:coleccion]

    colecciones = Rails.cache.fetch("br_#{params[:catalogo_id]}__")[:resultados].try(:keys)
    existen = (colecciones & "COLECCION_#{params[:coleccion].upcase}".constantize).any?
    self.resp = { estatus: existen }
  end


  private

  def consulta_especies_por_region
    resultados = Geoportal::Snib.select('idnombrecatvalido, COUNT(*) AS nregistros').group(:idnombrecatvalido).order('nregistros DESC')
    
    if campo_tipo_region.present? && params[:region_id].present?
      resultados = resultados.where("#{campo_tipo_region}=#{params[:region_id]}")
    elsif campo_tipo_region.present?  # Cuando es el conteo general por alguna division politica
      resultados = resultados.where("#{campo_tipo_region} IS NOT NULL") 
    end

    if resultados.length > 0
      { estatus: true, resultados: resultados.map{ |r| {r.idnombrecatvalido => r.nregistros} }.reduce({}, :merge) }
    else
      { estatus: false, msg: 'Sin resultados en esta región' }
    end
  end  

  # Regresa todos los ejemplares de la especie seleccionada, de una forma simplificada
  def consulta_ejemplares_por_region
    resultados = Geoportal::Snib.select(:id, :latitud, :longitud, :tipocoleccion).where(idnombrecatvalido: params[:catalogo_id])

    if campo_tipo_region.present? && params[:region_id].present?
      resultados = resultados.where("#{campo_tipo_region}=#{params[:region_id]}")
    elsif campo_tipo_region.present?  # Cuando son los registros de alguna division politica en particular
      resultados = resultados.where("#{campo_tipo_region} IS NOT NULL") 
    end

    return { estatus: false, msg: 'Sin resultados' } unless resultados.any?
    ejemplares = {}

    resultados.each do |r|
      ejemplares[r.tipocoleccion] = [] unless ejemplares[r.tipocoleccion].present?
      ejemplares[r.tipocoleccion] << [r.longitud, r.latitud, r.id]
    end
    
    { estatus: true, resultados: ejemplares } 
  end
  
  # Regresa la llave foranea dependiendo el tipo de region
  def tipo_region_a_llave_foranea
    case params[:tipo_region]
    when 'estado'
      self.campo_tipo_region = 'entid'
    when 'municipio'
      self.campo_tipo_region = 'munid'
    when 'anp'
      self.campo_tipo_region = 'anpid'
    when 'ecorregion'
      self.campo_tipo_region = 'ecorid'
    else  
      self.campo_tipo_region = nil
    end 
  end

  # Validacion de los registros de la especie
  def valida_registros
    # Vemos la existencia del cache la primera vez, en caso de no existir consultamos en vivo
    ejemplares unless Rails.cache.exist?("br_#{params[:catalogo_id]}__")
    
    return self.resp = { estatus: false, msg: "No existe el cache: br_#{params[:catalogo_id]}__" } unless Rails.cache.exist?("br_#{params[:catalogo_id]}__")
    return self.resp = { estatus: false, msg: "Respuesta erronea del cache: br_#{params[:catalogo_id]}__" } unless Rails.cache.fetch("br_#{params[:catalogo_id]}__")[:estatus]
    self.resp = { estatus: true }
  end 

  # REVISADO: Crea o devuleve la capreta de los geodatos
  def carpeta_geodatos
    carpeta = Rails.root.join('public', 'geodatos', params[:taxon].id.to_s)
    FileUtils.mkpath(carpeta, :mode => 0755) unless File.exists?(carpeta)
    carpeta
  end

  # REVISADO: Transforma los ejemplares del SNIB a kml
  def to_kml
    h = HTMLEntities.new  # Para codificar el html y no marque error en el KML
    nombre_cientifico = h.encode(params[:taxon].nombre_cientifico)
    nombre_comun = h.encode(params[:taxon].nom_com_prin(true))
    nombre = nombre_comun.present? ? "<b>#{nombre_comun}</b> <i>(#{nombre_cientifico})</i>" : "<i><b>#{nombre_cientifico}</b></i>"

    self.kml = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
    self.kml << "<kml xmlns=\"http://www.opengis.net/kml/2.2\">\n"
    self.kml << "<Document>\n"
    self.kml << "<Style id=\"normalPlacemark\">\n"
    self.kml << "<IconStyle><scale>1.5</scale>\n"
    self.kml << "<Icon>\n"
    self.kml << "<href>https://maps.google.com/mapfiles/kml/paddle/red-blank.png</href>\n"
    self.kml << "</Icon>\n"
    self.kml << "</IconStyle>\n"
    self.kml << "</Style>\n"

    registros.each do |registro|
      self.kml << "<Placemark>\n"
      self.kml << "<description>\n"
      self.kml << "<![CDATA[\n"
      self.kml << "<div>\n"
      self.kml << "<h4>\n"
      self.kml << "<a href=\"#{CONFIG.enciclovida_url}/especies/#{params[:taxon].id}\">#{nombre}</a>\n"
      self.kml << "</h4>\n"
      self.kml << "<dl>\n"

      self.kml << "<dt>Localidad</dt> <dd>#{registro.localidad}</dd>\n"
      self.kml << "<dt>Municipio</dt> <dd>#{registro.municipiomapa}</dd>\n"
      self.kml << "<dt>Estado</dt> <dd>#{registro.estadomapa}</dd>\n"
      self.kml << "<dt>País</dt> <dd>#{registro.paismapa}</dd>\n"
      self.kml << "<dt>Fecha</dt> <dd>#{registro.fechacolecta}</dd>\n"
      self.kml << "<dt>Nombre del colector</dt> <dd>#{registro.colector}</dd>\n"
      self.kml << "<dt>Colección</dt> <dd>#{registro.coleccion}</dd>\n"
      self.kml << "<dt>Institución</dt> <dd>#{registro.institucion}</dd>\n"
      self.kml << "<dt>País de la colección</dt> <dd>#{registro.paiscoleccion}</dd>\n"

      if registro.proyecto.present? && registro.urlproyecto.present?
        self.kml << "<dt>Proyecto:</dt> <dd><a href=\"#{registro.urlproyecto}\">#{registro.proyecto}</a></dd>\n"
      else
        self.kml << "<dt>Proyecto:</dt> <dd>#{registro.proyecto}</dd>\n"
      end

      self.kml << "</dl>\n"

      self.kml << "<span><text>Más información: </text><a href=\"http://#{registro.urlejemplar}\">consultar</a></span>\n"

      self.kml << "</div>\n"
      self.kml << "]]>\n"
      self.kml << "</description>\n"
      self.kml << '<styleUrl>#normalPlacemark</styleUrl>'
      self.kml << "<Point>\n<coordinates>\n#{registro.longitud},#{registro.latitud}\n</coordinates>\n</Point>\n"
      self.kml << "</Placemark>\n"
    end

    self.kml << "</Document>\n"
    self.kml << '</kml>'
  end

  # REVISADO: Comprime el kml a kmz
  def kmz(nombre)
    archvo_zip = "#{nombre}.zip"
    system "zip -j #{archvo_zip} #{nombre}.kml"
    File.rename(archvo_zip, "#{nombre}.kmz")
  end

end
