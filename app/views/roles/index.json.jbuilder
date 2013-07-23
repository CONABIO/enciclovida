json.array!(@roles) do |rol|
  json.extract! rol, 
  json.url rol_url(rol, format: :json)
end