json.array!(@regiones) do |region|
  json.extract! region, 
  json.url region_url(region, format: :json)
end