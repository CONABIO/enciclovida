class XenoCantoService
  def obtener_cantos(taxon)
    recordings = []

    begin
      genero, especie = taxon.to_s.strip.split(/\s+/, 2)

      if genero.blank? || especie.blank?
        return [{ msg: "Taxón inválido: #{taxon}" }]
      end

      query = ERB::Util.url_encode("gen:#{genero} sp:#{especie}")

      url = "#{CONFIG.xeno_canto.api}?query=#{query}&key=#{CONFIG.xeno_canto.api_key}"

      resp = RestClient.get(url)
      jres = JSON.parse(resp.body)

      if jres['numRecordings'].to_i > 0
        jres['recordings'].first(24).each do |recording|
          # Utilizar el enlace directo al audio
          if recording['file'].present?
            recording['url'] = recording['file']
          elsif recording['url'].present?
            recording['url'] = recording['url'].sub(%r{^//}, '')
          end

          recordings << recording
        end
      else
        recordings << { msg: "No hay resultados para #{taxon.capitalize.gsub('+', ' ')}" }
      end

    rescue => e
      Rails.logger.error e.class
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.join("\n")

      recordings << { msg: "Hubo un error: #{e.class} - #{e.message}" }
    end

    recordings
  end
end