# app/indices/article_index.rb
ThinkingSphinx::Index.define :especie, :with => :active_record do

  indexes nombre_cientifico
  indexes categoria_taxonomica.nombre_categoria_taxonomica, :as => :cat_tax
  indexes especies_regiones.region.nombre_region, :as => :reg
  indexes especies_regiones.nombres_regiones.nombre_comun.nombre_comun, :as => :nombre
  #where "categoria_taxonomica_id = 50"
  #indexes "LOWER(nombre_comun)", :as => :nombre_comun, :sortable => true
  #has lengua, created_at, updated_at
end