json.array!(@nombres_comunes) do |nombre_comun|
  json.extract! nombre_comun, "#{:nombre_comun}"
  json.nombre 'algo'
end
