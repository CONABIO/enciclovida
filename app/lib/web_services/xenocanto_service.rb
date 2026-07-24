class XenoCantoService
    def obtener_cantos(taxon)
        taxon_escape = ERB::Util.url_encode(taxon)
        url = "https://www.xeno-canto.org/api/2/recordings?query=#{taxon_escape}"
        recordings = []
        begin
            resp = RestClient.get url
            jres = JSON.parse(resp)

            if jres['numRecordings'].to_i > 0 # 
                i = 0
                while i < 24
                    file = jres['recordings'][i]['url']
                    file = file[2..file.length]
                    jres['recordings'][i]['url'] = file
                    recordings.push(jres['recordings'][i])
                    i+=1
                end
            else
                recordings << {msg: "No hay resultados para #{taxon.capitalize.gsub('+', ' ')}"}
            end
        rescue => e
          Rails.logger.error e.class
          Rails.logger.error e.message
          Rails.logger.error e.backtrace.join("\n")

          [{ msg: "Hubo un error: #{e.class} - #{e.message}" }]
        end
        recordings
    end
end