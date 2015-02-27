class AddGeoserverInfoToProveedores < ActiveRecord::Migration
  def change
    change_table(:proveedores) do |t|
      t.string :geoserver_info
    end
  end
end
