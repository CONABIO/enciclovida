json.array!(@roles_categorias_contenido) do |rol_categorias_contenido|
  json.extract! rol_categorias_contenido, :categoria_contenido_id, :rol_id
  json.url rol_categorias_contenido_url(rol_categorias_contenido, format: :json)
end