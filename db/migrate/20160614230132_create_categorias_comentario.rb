class CreateCategoriasComentario < ActiveRecord::Migration
  def change
    create_table :categorias_comentario do |t|
      t.string :nombre, null: false
      t.string :ancestry
      t.timestamps
    end
  end
end
