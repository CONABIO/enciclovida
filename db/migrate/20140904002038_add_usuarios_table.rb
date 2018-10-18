class AddUsuariosTable < ActiveRecord::Migration[5.1]
  def change
    create_table "usuarios", force: true do |t|
      t.string   "usuario",                     null: false
      t.string   "correo",                      null: false
      t.string   "nombre",                      null: false
      t.string   "apellido",                    null: false
      t.string   "institucion",                 null: false
      t.string   "grado_academico",             null: false
      t.string   "contrasenia",                 null: false
      t.datetime "created_at",                  null: false
      t.datetime "updated_at",                  null: false
      t.integer  "rol_id",          default: 1, null: false
      t.string   "salt"
    end
  end
end
