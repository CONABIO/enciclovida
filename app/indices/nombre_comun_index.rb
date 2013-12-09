# app/indices/article_index.rb
ThinkingSphinx::Index.define :nombre_comun, :with => :active_record do
  indexes nombre_comun, :as => :nom
  #indexes where "nombre_comun LIKE '%gal%'"
end