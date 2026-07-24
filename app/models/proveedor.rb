# REVISADO: Consulta la ficha de naturalista por medio de su API nodejs
# TODO se requiere un boton de borrar cache
def ficha_naturalista_api_nodejs
  cache_key = "ficha_naturalista_#{especie_id}"

  if Rails.cache.exist?(cache_key)
    self.jres = Rails.cache.fetch(cache_key)
    return
  end

  resultado = Rails.cache.fetch(cache_key, expires_in: eval(CONFIG.cache.ficha_naturalista)) do

    if naturalista_id.blank?
      t = especie
      t.ficha_naturalista_por_nombre
      self.jres = t.jres

      return jres if jres.present?

      return {
        estatus: false,
        msg: "No fue posible obtener el naturalista_id"
      }
    end

    begin
      url = "#{CONFIG.inaturalist_api}/taxa/#{naturalista_id}?all_names=true"

      Rails.logger.info "[iNaturalist] GET #{url}"

      resp = RestClient.get(url)
      ficha = JSON.parse(resp.body)

      if ficha['total_results'] == 1
        {
          estatus: true,
          ficha: ficha['results'][0]
        }
      else
        {
          estatus: false,
          msg: 'Tiene más de un resultado, solo debería ser uno por ser ficha'
        }
      end

    rescue => e
      Rails.logger.error "[iNaturalist] #{e.class}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      {
        estatus: false,
        error: e.class.to_s,
        msg: e.message
      }
    end
  end

  self.jres = resultado.present? ? resultado : {
    estatus: false,
    msg: 'Error en el cache'
  }
end