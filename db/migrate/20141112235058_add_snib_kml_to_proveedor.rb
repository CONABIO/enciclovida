class AddSnibKmlToProveedor < ActiveRecord::Migration[5.1]
  def change
    change_table(:proveedores) do |t|
      ## Campo adicional para el SNIB
      t.text :snib_kml
    end
  end
end
