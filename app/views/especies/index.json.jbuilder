json.array!(@especies) do |especie|
  json.extract! especie, :nombre, :estatus, :fuente, :nombre_autoridad, :numero_filogenetico, :cita_nomenclatural, :sis_clas_cat_dicc, :anotacion
  json.url especie_url(especie, format: :json)
end