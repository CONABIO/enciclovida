#antes de correr el script crear la carpeta db/blurrily/, OJO esto solo es para ambiente de pruebas
require 'blurrily/map'
map = Blurrily::Map.new

Especie.all.each do |taxon|
  map.put(taxon.nombre_cientifico, taxon.id)
end

map.save('/home/calonso/ProyectosRoR/buscador/db/blurrily/data.trigrams')