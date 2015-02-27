class RemoveColumnsKmlToProveedores < ActiveRecord::Migration
  def change
      remove_column :proveedores, :snib_kml
      remove_column :proveedores, :naturalista_kml
  end
end
