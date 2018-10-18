class CreateComentarios < ActiveRecord::Migration[5.1]
  def change
    create_table :comentarios do |t|
      t.text :comentario, :null => false
      t.string :correo
      t.string :nombre
      t.integer :especie_id, :null => false
      t.integer :usuario_id
      t.timestamps
    end
  end
end
