json.array!(@tipos_regiones) do |tipo_region|
  json.extract! tipo_region, 
  json.url tipo_region_url(tipo_region, format: :json)
end