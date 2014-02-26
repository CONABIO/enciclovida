# app/indices/article_index.rb
ThinkingSphinx::Index.define :nombre_comun, :with => :active_record do
  indexes nombre_comun, :sortable => true
  #indexes "LOWER(nombre_comun)", :as => :nombre_comun, :sortable => true
  #has lengua, created_at, updated_at
  #indexes where "nombre_comun LIKE '%gal%'"
end