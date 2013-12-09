json.array!(@categorias_taxonomica) do |categoria_taxonomica|
  json.extract! categoria_taxonomica, :id, :nombre_categoria_taxonomica, :nivel1, :nivel2
end