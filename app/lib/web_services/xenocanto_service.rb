class XenoCantoService
    def obtener_cantos(taxon)
        url = "https://www.xeno-canto.org/api/2/recordings?query=#{taxon.downcase.gsub(' ','+')}"
        url_escape = URI.escape(url)
        uri = URI.parse(url_escape)
        req = Net::HTTP::Get.new(url.to_s)
        recordings = []
        begin
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            res = http.request(req)
            jres = JSON.parse(res.body)
            if jres['recordings'].any? # 
                i = 0
                while i < 24
                    file = jres['recordings'][i]['file']
                    file = file[2..file.length]
                    jres['recordings'][i]['file'] = file
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
            [{msg: "Hubo algun error en la solicitud: #{e}. Intente de nuevo más tarde"}]
        end
        recordings
    end
end