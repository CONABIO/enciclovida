# app/indices/article_index.rb
ThinkingSphinx::Index.define :especie, :with => :active_record do

  indexes nombre_cientifico
  indexes categoria_taxonomica.nombre_categoria_taxonomica, :as => :cat_tax
  #where "categoria_taxonomica_id = 50"
  #indexes "LOWER(nombre_comun)", :as => :nombre_comun, :sortable => true
  #has lengua, created_at, updated_at
  #indexes where "nombre_comun LIKE '%gal%'"
  has categoria_taxonomica_id
end