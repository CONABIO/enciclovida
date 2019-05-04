class IUCNService

  # Consulta la categoria de riesgo de un taxon dado
  def consultaRiesgo(opts)
    @iucn = CONFIG.iucn.api
    @token = CONFIG.iucn.token

    url = "#{@iucn}/api/v3/species/#{opts[:nombre].limpia_ws}?token=#{@token}"
    url_escape = URI.escape(url)
    uri = URI.parse(url_escape)
    req = Net::HTTP::Get.new(uri.to_s)
    begin
      res = Net::HTTP.start(uri.host, uri.port, :read_timeout => CONFIG.iucn.timeout ) {|http| http.request(req) }
      jres = JSON.parse(res.body)['result']
      jres[0]['category'] if jres.any?
    rescue => e
      nil
    end
  end

  # Guarda en cache la respuesta del servicio
  def dameRiesgo(opc={})
    resp = Rails.cache.fetch("iucn_#{opc[:id]}", expires_in: eval(CONFIG.cache.iucn)) do
      iucn = consultaRiesgo(opc)
      I18n.t("iucn_ws.#{iucn.estandariza}", :default => iucn) if iucn.present?
    end

    resp
  end

  # Accede al archivo que contiene los assessments y la taxonomia dentro de la carpeta versiones_IUCN
  # NOTAS: Este archivo se baja de la pagina de IUCN y hay que unir el archivo de asswessments con el de taxonomy
  def actualiza_IUCN(archivo)
    csv_path = Rails.root.join('public', 'IUCN', archivo)
    bitacora.puts 'Nombre científico en IUCN,IUCN,Nombre científico en CAT,IdCAT,Estatus nombre,IdCAT valido,observaciones'
    return unless File.exists? csv_path

    CSV.foreach(csv_path, :headers => true) do |row|
      datos = []
      datos[0] = row['scientificName']
      datos[1] = row['redlistCategory']

      t = Especie.where(nombre_cientifico: row['scientificName'])

      if t.length == 1  # Caso más sencillo
        estatus = t.first.estatus
        datos[2] = t.first.nombre_cientifico
        datos[3] = t.first.scat.catalogo_id
        datos[4] = estatus

        # Para ver que se encuentre en el mismo reino y evitar homonimos
        reino = t.first.root.nombre_cientifico.estandariza
        unless row['kingdomName'].estandariza == reino
          datos[6] = 'Los reinos no coincidieron'
          next
        end

        if estatus == 2  # Quiere decir que es valido
          datos[5] = t.first.scat.catalogo_id
          datos[6] = 'Coincidencia exacta'
        elsif estatus == 1
          if taxon_valido = t.first.dame_taxon_valido
            datos[5] = taxon_valido.scat.catalogo_id
            datos[6] = 'Es un sinónimo y encontró el válido'
          else
            datos[6] = 'Es un sinónimo y hubo problemas al encontrar el válido'
          end
        end

      elsif  t.length == 0 # Sin resultados
        # Intento buscar por medio de exp regulares
        Especie.where("#{Especie.attribute_alias(:nombre_cientifico)} regexp ?","[]")
        datos[6] = 'Sin coincidencias'
      else  # Más de un resultado, hay un homonimo
        datos[6] = 'Más de un resultado (homonímia)'
      end

      bitacora.puts datos.join(',')
    end

    bitacora.close
  end

  # Bitacora especial para catalogos, antes de correr en real, pasarsela
  def bitacora
    log_path = Rails.root.join('log', Time.now.strftime('%Y-%m-%d_%H%m') + '_IUCN.csv')
    @@bitacora ||= File.new(log_path, 'a+')
  end

end

