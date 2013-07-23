json.array!(@tipos_distribuciones) do |tipo_distribucion|
  json.extract! tipo_distribucion, 
  json.url tipo_distribucion_url(tipo_distribucion, format: :json)
end