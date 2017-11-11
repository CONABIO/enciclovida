class GithubService

  def dame_issues
    ruta = Rails.root.join('tmp', 'cache')
    archivo = ruta.join('github_issues')

    if existe_cache?('github_issues')
      if File.exist?(archivo)
        JSON.parse(File.read(archivo))
      else
        [{'title' => 'Error al leer el archivo', 'body' => 'Problema al guardar el cache de github'}]
      end

    else
      escribe_cache('github_issues', CONFIG.github.issues)
      jres = lee_issues

      FileUtils.mkpath(ruta, :mode => 0755) unless File.exists?(ruta)
      File.open(archivo, 'w') { |f| f.write(jres.to_json) }
      jres
    end
  end

  def lee_issues(type='issues')
    url = CONFIG.github.api << "/#{type}?state=closed"
    url = url << '&labels=new feature' if type == 'issues'
    url = url << '&sort=updated' if type == 'issues'

    url_escape = URI.escape(url)
    uri = URI.parse(url_escape)
    req = Net::HTTP::Get.new(uri.to_s)
    req['Accept'] = 'application/vnd.github.v3+json'

    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')
      res = http.request(req)

      jres = JSON.parse(res.body)
    rescue => e
      jres = [{'title' => 'No hay nuevas noticias', 'body' => 'Servicio de noticias abajo'}]
    end

    jres[0..4]
  end

  # Este servicio se actualizará una vez cada hora, ya que github permite solo 60 request/hr sin autenticar,
  # y 5k/hr con el metodo de autenticación
  def escribe_cache(recurso, tiempo = 1.hour)
    Rails.cache.write(recurso, true, expires_in: tiempo)
  end

  def existe_cache?(recurso)
    Rails.cache.exist?(recurso)
  end

  def borra_cache(recurso)
    Rails.cache.delete(recurso)
  end
end