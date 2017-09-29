class BorraTablasEstorbosas < ActiveRecord::Migration
  def change
    drop_table :metadatos
    drop_table :metadato_especies
    drop_table :photos
    drop_table :taxon_photos
    drop_table :validaciones
    drop_table :filtros
    drop_table :iconos
  end
end
