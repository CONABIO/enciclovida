class CreateComentariosProveedores < ActiveRecord::Migration
  def change
    create_table :comentarios_proveedores do |t|
      t.integer :tipo_proveedor, null: false
      t.integer :comentario_id, null: false
      t.integer :proveedor_id, null: false
      t.timestamps
    end
  end
end
