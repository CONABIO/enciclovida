json.array!(@comentarios) do |comentario|
  json.extract! comentario, 
  json.url comentario_url(comentario, format: :json)
end