class CreateCategoriasComentario < ActiveRecord::Migration[5.1]
  def change
    create_table :categorias_comentario do |t|
      t.string :nombre, null: false
      t.string :ancestry
      t.timestamps
    end
  end
end
