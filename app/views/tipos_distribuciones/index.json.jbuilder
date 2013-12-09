json.array!(@tipos_distribuciones) do |tipo_distribucion|
  json.extract! tipo_distribucion, :id, :descripcion
end