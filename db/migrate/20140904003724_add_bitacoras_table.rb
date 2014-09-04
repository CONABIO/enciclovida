class AddBitacorasTable < ActiveRecord::Migration
  def change
    create_table "bitacoras", force: true do |t|
      t.text     "descripcion"
      t.datetime "created_at",                                                            null: false
      t.datetime "updated_at",                                                            null: false
      t.integer  "usuario_id",                                                            null: false
    end
  end
end
