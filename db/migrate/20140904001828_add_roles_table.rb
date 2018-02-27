class AddRolesTable < ActiveRecord::Migration[5.1]
  def change
    create_table "roles", force: true do |t|
      t.string   "nombre_rol",                                 null: false
      t.text     "atributos_base"
      t.text     "tablas_adicionales"
      t.string   "permisos"
      t.text     "taxonomia_especifica"
      t.text     "usuarios_especificos"
      t.integer  "es_admin",             limit: 1, default: 0, null: false
      t.integer  "es_super_usuario",     limit: 1, default: 0, null: false
      t.datetime "created_at",                                 null: false
      t.datetime "updated_at",                                 null: false
    end
  end
end
