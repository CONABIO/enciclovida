class AddListasTable < ActiveRecord::Migration
  def change
    create_table "listas", force: true do |t|
      t.string   "nombre_lista",                                                                     null: false
      t.text     "columnas"
      t.string   "formato"
      t.integer  "esta_activa",     limit: 1, default: 0,                                            null: false
      t.text     "cadena_especies"
      t.datetime "created_at",                                                                       null: false
      t.datetime "updated_at",                                                                       null: false
      t.integer  "usuario_id",                                                                       null: false
    end
  end
end
