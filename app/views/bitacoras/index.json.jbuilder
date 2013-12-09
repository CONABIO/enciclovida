json.array!(@bitacoras) do |bitacora|
  json.extract! bitacora, 
  json.url bitacora_url(bitacora, format: :json)
end