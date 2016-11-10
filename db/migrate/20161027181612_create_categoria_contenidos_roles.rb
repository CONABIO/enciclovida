class CreateCategoriaContenidosRoles < ActiveRecord::Migration
  def change
    create_table :categoria_contenidos_roles do |t|
      t.integer :categoria_contenido_id
      t.integer :rol_id

      t.timestamps
    end
  end
end
