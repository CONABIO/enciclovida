class AddNaturalistaObsToProveedores < ActiveRecord::Migration
  def change
    change_table(:proveedores) do |t|
      t.text :naturalista_obs
    end
  end
end
