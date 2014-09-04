class AddPhotosTable < ActiveRecord::Migration
  def change
    create_table "photos", force: true do |t|
      t.integer  "usuario_id"
      t.string   "native_photo_id"
      t.string   "square_url"
      t.string   "thumb_url"
      t.string   "small_url"
      t.string   "medium_url"
      t.string   "large_url"
      t.string   "original_url",      limit: 512
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "native_page_url"
      t.string   "native_username"
      t.string   "native_realname"
      t.integer  "license"
      t.string   "type"
      t.string   "file_content_type"
      t.string   "file_file_name"
      t.integer  "file_file_size"
      t.boolean  "file_processing"
      t.boolean  "mobile",                        default: false
      t.datetime "file_updated_at"
      t.text     "metadata"
    end

    add_index "photos", ["native_photo_id"], name: "index_flickr_photos_on_flickr_native_photo_id", using: :btree
    add_index "photos", ["usuario_id"], name: "index_photos_on_user_id", using: :btree
  end
end
