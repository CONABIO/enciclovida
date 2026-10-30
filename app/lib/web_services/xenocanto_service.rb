
class WebServices::XenoCantoService < WebServices::BaseService
  MAX_GRABACIONES = 24

  def obtener_cantos(taxon)
    taxon = taxon.to_s.strip
    genero, especie = taxon.split(/\s+/, 2)

    if genero.blank? || especie.blank?
      return [{ msg: "Taxón inválido: #{taxon}" }]
    end

    api_url = ENV.fetch("XENO_CANTO_API_URL")
    api_key = ENV.fetch("XENO_CANTO_API_KEY")

    if api_key.blank?
      raise KeyError, "XENO_CANTO_API_KEY está vacía"
    end

    query = URI.encode_www_form(
      query: "gen:#{genero} sp:#{especie}",
      key: api_key
    )

    respuesta = get_json("#{api_url}?#{query}")

    if respuesta["numRecordings"].to_i.zero?
      return [{ msg: "No hay resultados para #{taxon}" }]
    end

    respuesta.fetch("recordings", []).first(MAX_GRABACIONES).map do |grabacion|
      normalizar_grabacion(grabacion)
    end

  rescue WebServices::BaseService::RequestError => e
    Rails.logger.error(
      "[XenoCanto] Error de consulta: #{e.message}"
    )

    [{ msg: "No fue posible consultar Xeno-canto" }]

  rescue KeyError, URI::InvalidURIError => e
    Rails.logger.error(
      "[XenoCanto] Error de configuración: #{e.class}"
    )

    [{ msg: "Error de configuración de Xeno-canto" }]

  rescue StandardError => e
    Rails.logger.error(
      "[XenoCanto] #{e.class}: #{e.message}"
    )

    [{ msg: "Ocurrió un error al obtener las grabaciones" }]
  end

  private

  def normalizar_grabacion(grabacion)
    grabacion["file"] = normalizar_url(grabacion["file"])
    grabacion["url"] = normalizar_url(grabacion["url"])

    if grabacion["sono"].is_a?(Hash)
      grabacion["sono"]["small"] = normalizar_url(
        grabacion["sono"]["small"]
      )

      grabacion["sono"]["med"] = normalizar_url(
        grabacion["sono"]["med"]
      )

      grabacion["sono"]["large"] = normalizar_url(
        grabacion["sono"]["large"]
      )
    end

    grabacion
  end

  def normalizar_url(url)
    return nil if url.blank?

    url = url.to_s.strip

    return "https:#{url}" if url.start_with?("//")
    return url if url.start_with?("https://")
    return nil if url.start_with?("http://")

    "https://#{url.sub(%r{\A/+}, '')}"
  end
end
