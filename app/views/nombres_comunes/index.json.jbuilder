json.array!(@nombres_comunes) do |nombre_comun|
  json.extract! nombre_comun, :id
  @aqui = nombre_comun.id
  json.term nombre_comun.nombre_comun
  json.score 85
  json.data do
    json.array!(nombre_comun.especies.order('nombre_cientifico ASC')) do |especie|
        json.extract! especie, :nombre_cientifico
        json.extract! especie.categoria_taxonomica, :nombre_categoria_taxonomica
    end
  end
end
