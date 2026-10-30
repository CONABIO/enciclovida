
class WebServices::TropicosService < WebServices::BaseService
  def initialize(options = {})
    @service_name = "Tropicos"
    @server = options[:server] || CONFIG.site_url
    @timeout = options[:timeout] || 8
    @debug = options[:debug] || false

    Rails.logger.debug("[TropicosService] Servicio inicializado")
  end

  # Obtiene el NameId de una especie a partir de su nombre científico.
  def get_id_name(name)
    nombre = name.to_s.strip

    return [{ msg: "Nombre inválido" }] if nombre.blank?

    respuesta = consultar(
      "Search",
      name: nombre,
      type: "exact"
    )

    if respuesta.is_a?(Array) && respuesta.first.is_a?(Hash)
      if respuesta.first["Error"].present?
        return [{ msg: "no se encontró coincidencia para #{nombre}" }]
      end
    end

    respuesta
  rescue WebServices::BaseService::RequestError => e
    Rails.logger.warn(
      "[TropicosService] Error buscando #{nombre}: #{e.message}"
    )

    [{ msg: "Hubo un error en la solicitud. Intente de nuevo más tarde" }]
  end

  # Obtiene las imágenes de una especie mediante su NameId.
  def get_media(id_name)
    return [] if id_name.blank?

    consultar("#{id_name}/Images")
  rescue WebServices::BaseService::RequestError => e
    Rails.logger.warn(
      "[TropicosService] Error consultando imágenes #{id_name}: #{e.message}"
    )

    [{ msg: "Hubo un error en la solicitud. Intente de nuevo más tarde" }]
  end

  # Conservamos el nombre original por compatibilidad.
  def agerga_proveedor_id_tropicos(especie, proveedor = false)
    name_id = get_id_name(especie.nombre_cientifico)

    return nil unless name_id.is_a?(Array)

    primer_resultado = name_id.first
    return nil unless primer_resultado.is_a?(Hash)

    return nil if primer_resultado[:msg].present?

    tropicos_id = primer_resultado["NameId"]
    return nil if tropicos_id.blank?

    Proveedor.create(
      especie_id: especie.id,
      tropico_id: tropicos_id
    )

    tropicos_id
  end

  private

  def consultar(ruta, parametros = {})
    api_url = CONFIG.tropicos.api.to_s
    api_key = CONFIG.tropicos.key.to_s

    if api_url.blank? || api_key.blank?
      raise WebServices::BaseService::RequestError,
            "Configuración de Tropicos incompleta"
    end

    base = api_url.end_with?("/") ? api_url : "#{api_url}/"
    uri = URI.parse("#{base}#{ruta}")

    query = {
      apikey: api_key,
      format: "json"
    }.merge(parametros)

    uri.query = URI.encode_www_form(query)

    respuesta = get_json(uri.to_s)

    respuesta.nil? ? [] : respuesta
  end
end
