json.array!(@nombre_regiones_bibliografias) do |nombre_region_bibliografia|
  json.extract! nombre_region_bibliografia, 
  json.url nombre_region_bibliografia_url(nombre_region_bibliografia, format: :json)
end