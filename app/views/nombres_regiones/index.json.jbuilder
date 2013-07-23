json.array!(@nombres_regiones) do |nombr_regione|
  json.extract! nombr_regione, 
  json.url nombr_regione_url(nombr_regione, format: :json)
end