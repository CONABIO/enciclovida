json.array!(@especies_regiones) do |especie_region|
  json.extract! especie_region, 
  json.url especie_region_url(especie_region, format: :json)
end