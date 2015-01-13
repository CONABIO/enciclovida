json.array!(@metadatos) do |metadato|
  json.extract! metadato, 
  json.url metadato_url(metadato, format: :json)
end