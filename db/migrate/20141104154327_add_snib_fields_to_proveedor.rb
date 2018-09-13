class AddSnibFieldsToProveedor < ActiveRecord::Migration[5.1]
  change_table(:proveedores) do |t|
    ## Campos adicionales para el SNIB
    t.integer :snib_id
    t.string :snib_reino
  end
end
