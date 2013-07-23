json.array!(@listas) do |lista|
  json.extract! lista, 
  json.url lista_url(lista, format: :json)
end