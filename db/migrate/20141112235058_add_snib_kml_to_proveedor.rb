class AddSnibKmlToProveedor < ActiveRecord::Migration
  def change
    change_table(:proveedores) do |t|
      ## Campo adicional para el SNIB
      t.text :snib_kml
    end
  end
end
