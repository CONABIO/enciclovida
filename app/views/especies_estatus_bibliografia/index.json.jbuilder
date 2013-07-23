json.array!(@especies_estatus_bibliografia) do |especie_estatus_bibliografia|
  json.extract! especie_estatus_bibliografia, 
  json.url especie_estatus_bibliografia_url(especie_estatus_bibliografia, format: :json)
end