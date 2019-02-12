class AddTropicosToProveedores < ActiveRecord::Migration[5.1]
  def change
    add_column :proveedores, :tropico_id, :string
  end
end
