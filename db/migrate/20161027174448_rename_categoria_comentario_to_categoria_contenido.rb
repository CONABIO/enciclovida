class RenameCategoriaComentarioToCategoriaContenido < ActiveRecord::Migration[5.1]
  def self.up
    rename_table "categorias_comentario", "categorias_contenido"
  end

  def self.down
    rename_table "categorias_contenido", "categorias_comentario"
  end
end
