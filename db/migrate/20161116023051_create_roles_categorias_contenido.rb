class CreateRolesCategoriasContenido < ActiveRecord::Migration
  def change
    create_table :roles_categorias_contenido do |t|
      t.integer :categoria_contenido_id
      t.integer :rol_id

      t.timestamps
    end
  end
end
