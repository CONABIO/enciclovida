json.array!(@especies_catalogo) do |especie_catalogo|
  json.extract! especie_catalogo, 
  json.url especie_catalogo_url(especie_catalogo, format: :json)
end