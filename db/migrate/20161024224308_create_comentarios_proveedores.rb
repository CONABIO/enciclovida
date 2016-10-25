class CreateComentariosProveedores < ActiveRecord::Migration
  def change
    create_table :comentarios_proveedores do |t|
      t.integer :comentario_id, null: false
      t.string :proveedor_id, null: false
      t.timestamps
    end
  end
end
