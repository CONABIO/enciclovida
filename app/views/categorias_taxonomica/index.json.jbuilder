json.array!(@categorias_taxonomica) do |categoria_taxonomica|
  json.extract! categoria_taxonomica, 
  json.url categoria_taxonomica_url(categoria_taxonomica, format: :json)
end