class TropicosController < ApplicationController

  def tropico_especie
    taxonNC = Especie.find(params['id']).nombre_cientifico
    ts_req = Tropicos_Service.new

    @name_id = ts_req.get_id_name('poa annua')
    @array = ts_req.get_media(@name_id[0]["NameId"])
  end
end
