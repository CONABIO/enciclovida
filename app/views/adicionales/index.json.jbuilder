json.array!(@adicionales) do |adicional|
  json.extract! adicional, 
  json.url adicional_url(adicional, format: :json)
end