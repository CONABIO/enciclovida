
class WebServices::MacaulayService < WebServices::BaseService

  def dameMedia_nc(taxonNC, type, page = 1, min_page_size = 20)
    cornell = CONFIG.cornell.api_rp.presence || CONFIG.cornell.api

    if cornell.blank?
      return [{ msg: "El servicio de Macaulay Library no está configurado" }]
    end

    uri = URI.parse(cornell)

    parametros = URI.decode_www_form(uri.query.to_s)
    parametros.reject! { |clave, _| %w[sciName mediaType taxaLocale count].include?(clave) }

    parametros += [
      ["sciName", taxonNC.to_s],
      ["mediaType", type.to_s],
      ["taxaLocale", "es"],
      ["count", min_page_size.to_i.to_s]
    ]

    uri.query = URI.encode_www_form(parametros)

    respuesta = get_json(
      uri.to_s,
      headers: { "key" => CONFIG.cornell.key.to_s }
    )

    if respuesta.is_a?(Hash) && respuesta["message"].present?
      return [{ msg: "No se encontró coincidencia para #{taxonNC}" }]
    end

    respuesta

  rescue WebServices::BaseService::RequestError => e
    Rails.logger.warn(
      "[MacaulayService] Error consultando #{taxonNC}: #{e.message}"
    )

    mensaje = case e.status
              when 401, 403
                "Macaulay Library no autorizó la consulta"
              when 404
                "No se encontró coincidencia para #{taxonNC}"
              else
                "Macaulay Library no está disponible temporalmente"
              end

    [{ msg: mensaje }]

  rescue URI::InvalidURIError, ArgumentError => e
    Rails.logger.error(
      "[MacaulayService] Configuración inválida: #{e.class}"
    )

    [{ msg: "No fue posible consultar Macaulay Library" }]
  end

end
