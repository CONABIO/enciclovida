class CreateRolesCategoriasContenido < ActiveRecord::Migration[5.1]
  def change
    create_table :roles_categorias_contenido do |t|
      t.integer :categorias_contenido_id
      t.integer :rol_id

      t.timestamps
    end
  end
end
