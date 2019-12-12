class Eol

  attr_accessor :especie

  def api_eol(params = {})

    page = params[:page] || 1

    begin
      rest_client = RestClient::Request.execute(method: :get, url: "https://eol.org/api/search/1.0.json?q=#{especie.nombre_cientifico}&page=#{page}&key=&exact=true", timeout: 20)
      res = JSON.parse(rest_client)

      if res["results"][0]["title"] == especie.nombre_cientifico
        {estatus: true, resultados: res["results"][0]}
      else
        {estatus: false, msg: "Esta busqueda no contiene resultados"}
      end
    rescue => e
        {estatus: false, msg: e}

    end
  end
end


