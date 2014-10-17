class AddProveedoresTable < ActiveRecord::Migration
  def change
    create_table "proveedores", force: true do |t|
      t.integer  "especie_id",                  null: false
      t.integer  "naturalista_id",              null: true
      t.timestamps
    end
  end
end
