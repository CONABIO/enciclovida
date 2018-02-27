class AddFiltrosTable < ActiveRecord::Migration[5.1]
  def change
    create_table "filtros", force: true do |t|
      t.text     "html",                  null: false
      t.string   "sesion",     limit: 32, null: false
      t.datetime "created_at",            null: false
      t.datetime "updated_at",            null: false
      t.integer  "usuario_id"
    end

    add_index "filtros", ["sesion"], name: "index_filtros_on_sesion", using: :btree
  end
end
