json.array!(@especies_bibliografia) do |especie_bibliografia|
  json.extract! especie_bibliografia, 
  json.url especie_bibliografia_url(especie_bibliografia, format: :json)
end