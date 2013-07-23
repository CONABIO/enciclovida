json.array!(@nombres_comunes) do |nombr_comune|
  json.extract! nombr_comune, 
  json.url nombr_comune_url(nombr_comune, format: :json)
end