json.array!(@regiones_mapas) do |region_mapa|
  json.extract! region_mapa, 
  json.url region_mapa_url(region_mapa, format: :json)
end