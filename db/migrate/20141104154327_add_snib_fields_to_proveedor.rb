class AddSnibFieldsToProveedor < ActiveRecord::Migration
  change_table(:proveedores) do |t|
    ## Campos adicionales para el SNIB
    t.integer :snib_id
    t.string :snib_reino
  end
end
