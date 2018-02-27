class AddNaturalistaKmlToProveedores < ActiveRecord::Migration[5.1]
  def change
    change_table(:proveedores) do |t|
      t.text :naturalista_kml
    end
  end
end
