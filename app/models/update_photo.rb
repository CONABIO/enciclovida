require 'net/http'
require 'uri'
require 'json'
require 'openssl'
require 'rest-client'

class UpdatePhoto

  SSL_CA_FILE = '/etc/ssl/certs/ca-certificates.crt'.freeze

  def self.update_peces
    peces = Pmc::Pez
              .joins("INNER JOIN catalogocentralizado.Nombre n ON peces.especie_id = n.IdNombre")
              .where(
                "imagen LIKE ? OR imagen LIKE ? OR imagen LIKE ? OR imagen LIKE ?",
                "%enciclovida%",
                "%bdi.%",
                "%media.%",
                "%static.%"
              )
              .select("peces.especie_id, peces.imagen, n.TaxonCompleto")

    peces.find_each do |row|
      actualizar_imagen(Pmc::Pez, row, :imagen)
    end
  end

  def self.update_enciclo
    adicionales = Adicional
                    .joins("INNER JOIN catalogocentralizado.Nombre n ON adicionales.especie_id = n.IdNombre")
                    .where(
                      "foto_principal LIKE ? OR foto_principal LIKE ? OR foto_principal LIKE ? OR foto_principal LIKE ?",
                      "%enciclovida%",
                      "%bdi.%",
                      "%media.%",
                      "%static.%"
                    )
                    .select("adicionales.id, adicionales.foto_principal, n.TaxonCompleto")

    adicionales.find_each do |row|
      actualizar_imagen(Adicional, row, :foto_principal)
    end
  end

  def self.actualizar_imagen(model, row, campo)
    taxon = row[:TaxonCompleto]
    return if taxon == "Incertae sedis"

    foto_actual = row[campo]
    return if url_exists?(foto_actual)

    especie = taxon
                 .gsub("var.", "")
                 .gsub("subsp.", "")
                 .gsub("f.", "")
                 .strip

    nueva_img = fotoweb_conabio(especie)

    if nueva_img == "sin imagen"
      nueva_img = img_naturalista(especie)

      if nueva_img == "sin imagen"
        nueva_img = campo == :foto_principal ? " " : "/assets/app/peces/silueta.png"
      end
    end

    scope =
      if campo == :foto_principal
        model.where(id: row.id)
      else
        model.where(especie_id: row.especie_id)
      end

    scope.update_all(campo => nueva_img)
  end

  def self.url_exists?(url)
    return false if url.blank?

    RestClient::Request.execute(
      method: :head,
      url: url,
      verify_ssl: OpenSSL::SSL::VERIFY_PEER,
      ssl_ca_file: SSL_CA_FILE,
      timeout: 30,
      open_timeout: 10
    )

    true

  rescue RestClient::ExceptionWithResponse => e
    Rails.logger.warn("URL inválida #{url}: #{e.http_code}")
    false
  rescue StandardError => e
    Rails.logger.warn("Error verificando URL #{url}: #{e.message}")
    false
  end

  def self.consulta_api(url)
    url_escape = URI.escape(url)

    res = RestClient::Request.execute(
      method: :get,
      url: url_escape,
      headers: { accept: :json },
      verify_ssl: OpenSSL::SSL::VERIFY_PEER,
      ssl_ca_file: SSL_CA_FILE,
      timeout: 30,
      open_timeout: 10
    )

    JSON.parse(res.body)

  rescue RestClient::ExceptionWithResponse => e
    Rails.logger.warn("Error HTTP #{e.http_code} consultando #{url}")
    nil
  rescue StandardError => e
    Rails.logger.warn("Error al consultar API #{url}: #{e.class} - #{e.message}")
    nil
  end

  def self.fotoweb_conabio(especie)
    base_url = "https://bdi.conabio.gob.mx"
    url = "#{base_url}/fotoweb/archives/?q=#{URI.encode(especie)}"

    json_data = consulta_api(url)
    return "sin imagen" unless json_data && json_data["data"]

    mejor = json_data["data"]
              .select { |e| e["assetCount"].to_i > 0 }
              .max_by { |e| e["assetCount"].to_i }

    return "sin imagen" unless mejor

    img_data = consulta_api("#{base_url}#{mejor["href"]}")
    return "sin imagen" unless img_data

    preview = img_data.dig("assets", "data", 0, "previews", 0, "href")

    preview ? "#{base_url}#{preview}" : "sin imagen"
  end

  def self.img_naturalista(especie)
    url = "https://api.inaturalist.org/v1/observations?taxon_name=#{URI.encode(especie)}&order=desc&order_by=created_at"

    json_data = consulta_api(url)
    return "sin imagen" unless json_data

    return "sin imagen" unless json_data["total_results"].to_i > 0

    json_data.dig("results", 0, "taxon", "default_photo", "medium_url") || "sin imagen"
  end

end