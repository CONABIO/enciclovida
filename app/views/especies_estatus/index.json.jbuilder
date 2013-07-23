json.array!(@especies_estatus) do |especie_estatus|
  json.extract! especie_estatus, 
  json.url especie_estatus_url(especie_estatus, format: :json)
end