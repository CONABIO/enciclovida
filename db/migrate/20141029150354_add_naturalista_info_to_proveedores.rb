class AddNaturalistaInfoToProveedores < ActiveRecord::Migration
  def change
    change_table(:proveedores) do |t|
      t.text :naturalista_info
    end
  end
end
