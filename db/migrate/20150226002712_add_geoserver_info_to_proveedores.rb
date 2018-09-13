class AddGeoserverInfoToProveedores < ActiveRecord::Migration[5.1]
  def change
    change_table(:proveedores) do |t|
      t.string :geoserver_info
    end
  end
end
