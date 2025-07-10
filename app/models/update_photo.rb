require 'net/http'
require 'uri'
require 'json'
require 'openssl'

class UpdatePhoto 
  def self.update_peces
    peces = Pmc::Pez.joins("INNER JOIN catalogocentralizado.Nombre n ON peces.especie_id = n.IdNombre")
                .where("imagen LIKE ? OR imagen LIKE ? OR imagen LIKE ? OR imagen LIKE ?", "%enciclovida%", "%bdi.%", "%media.%","%static.%" )
                .select("peces.especie_id, peces.imagen, n.TaxonCompleto")
    peces.each { |row| actualizar_imagen(Pmc::Pez, row, :imagen) }
  end

  def self.update_enciclo
    adicionales = Adicional.joins("INNER JOIN catalogocentralizado.Nombre n ON adicionales.especie_id = n.IdNombre")
                       .where("foto_principal LIKE ? OR foto_principal LIKE ? OR foto_principal LIKE ? OR foto_principal LIKE ?", "%enciclovida%", "%bdi.%", "%media.%" ,"%static.%")
                       .select("adicionales.id, adicionales.foto_principal, n.TaxonCompleto")
    adicionales.each { |row| actualizar_imagen(Adicional, row, :foto_principal) }      
  end
  def self.actualizar_imagen(model, row, campo)
    taxon = row[:TaxonCompleto]
    return if taxon == "Incertae sedis"
    foto_actual = row[campo]
    return if url_exists?(foto_actual) 
    especie = taxon.gsub("var.", "").gsub("f.", "").gsub("subsp.", "").strip
    nueva_img = fotoweb_conabio(especie)
    
    if nueva_img != "sin imagen"
      if campo == :foto_principal
        model.where(id: row.id).update_all(campo => nueva_img)
      else
        model.where(especie_id: row.especie_id).update_all(campo => nueva_img)
      end
    else
      nueva_img = img_naturalista(especie)
      if campo == :foto_principal
        model.where(id: row.id).update_all(campo => (nueva_img != "sin imagen" ? nueva_img : " "))
      else
        model.where(especie_id: row.especie_id).update_all(campo => (nueva_img != "sin imagen" ? nueva_img : "/assets/app/peces/silueta.png"))
      end
    end
  end

  def self.url_exists?(url)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Head.new(uri.request_uri)
    response = http.request(request)

    response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPRedirection)
  rescue StandardError
    false
  end

  def self.consulta_api(url)
    uri = URI.parse(url.strip.gsub(" ", "%20"))
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    request = Net::HTTP::Get.new(uri.request_uri)
    request["Accept"] = "application/json"

    response = http.request(request)
    JSON.parse(response.body)
  rescue StandardError => e
    Rails.logger.warn("Error al consultar API: #{url}")
    nil
  end

  def self.fotoweb_conabio(especie)
    base_url = 'https://bdi.conabio.gob.mx'
    url = "#{base_url}/fotoweb/archives/?q=#{URI.encode(especie)}"

    json_data = consulta_api(url)
    return "sin imagen" unless json_data && json_data["data"]

    mejor_href = ""
    max_assets = 0

    json_data["data"].each do |element|
      next unless element["assetCount"].to_i > 0

      if mejor_href == "" || element["assetCount"].to_i > max_assets
        mejor_href = element["href"]
        max_assets = element["assetCount"].to_i
      end
    end

    if mejor_href != ""
      img_data = consulta_api("#{base_url}#{mejor_href}")
      preview = img_data.dig("assets", "data", 0, "previews", 0, "href")
      return "#{base_url}#{preview}" if preview
    end
    "sin imagen"
  end

  def self.img_naturalista(especie)
    url = "https://api.inaturalist.org/v1/observations?taxon_name=#{URI.encode(especie)}&order=desc&order_by=created_at"
    json_data = consulta_api(url)
    return "sin imagen" unless json_data

    if json_data["total_results"].to_i > 0
      photo = json_data.dig("results", 0, "taxon", "default_photo", "medium_url")
      return photo || "sin imagen"
    end
    "sin imagen"
  end
end