class AddNaturalistaKmlToProveedores < ActiveRecord::Migration
  def change
    change_table(:proveedores) do |t|
      t.text :naturalista_kml
    end
  end
end
