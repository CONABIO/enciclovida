class AddTaxonPhotosTable < ActiveRecord::Migration[5.1]
  def change
    create_table "taxon_photos", force: true do |t|
      t.integer  "especie_id", null: false
      t.integer  "photo_id",   null: false
      t.integer  "position"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "taxon_photos", ["especie_id"], name: "index_taxon_photos_on_taxon_id", using: :btree
    add_index "taxon_photos", ["photo_id"], name: "index_taxon_photos_on_photo_id", using: :btree
  end
end
